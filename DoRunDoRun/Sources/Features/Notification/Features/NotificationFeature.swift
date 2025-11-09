//
//  NotificationFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct NotificationFeature {
    @Dependency(\.notificationsUseCase) var notificationsUseCase
    @Dependency(\.notificationReadUseCase) var notificationReadUseCase

    @ObservableState
    struct State: Equatable {
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        
        var notifications: [NotificationViewState] = []
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true
        
        enum FailedRequestType: Equatable {
            case loadNotifications(page: Int)
            case markAsRead(id: Int)
        }
        var lastFailedRequest: FailedRequestType? = nil
    }

    enum Action: Equatable {
        case toast(ToastFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)

        case onAppear
        case loadNotifications(page: Int)
        case notificationsSuccess([NotificationsResult])
        case loadNextPageIfNeeded(currentItem: NotificationViewState?)
        case notificationsFailure(APIError)
        
        case markAsRead(Int)
        case notificationReadSuccess(Int)
        case notificationReadFailure(APIError)
        
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {
            
            // MARK: - 알림 목록 요청
            case .onAppear:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .send(.loadNotifications(page: 0))

            case let .loadNotifications(page):
                state.isLoading = true
                state.lastFailedRequest = .loadNotifications(page: page)
                return performLoadNotifications(page: page)

            case let .notificationsSuccess(results):
                state.isLoading = false
                if results.isEmpty {
                    state.hasNextPage = false
                } else {
                    let mapped = results.map { NotificationViewStateMapper.map(from: $0) }
                    if state.currentPage == 0 {
                        // 첫 페이지
                        state.notifications = mapped
                    } else {
                        // 다음 페이지 append
                        state.notifications.append(contentsOf: mapped)
                    }
                    state.currentPage += 1
                }
                return .none
                
            case let .loadNextPageIfNeeded(currentItem):
                guard let currentItem else { return .none }
                guard !state.isLoading && state.hasNextPage else { return .none }

                // 데이터 개수에 따라 thresholdIndex를 안전하게 계산
                let threshold = max(state.notifications.count - 5, 0)
                if let currentIndex = state.notifications.firstIndex(where: { $0.id == currentItem.id }),
                   currentIndex >= threshold {
                    let nextPage = state.currentPage + 1
                    print("[DEBUG] 다음 페이지 요청: \(nextPage)")
                    return .send(.loadNotifications(page: nextPage))
                }
                return .none

            case let .notificationsFailure(apiError):
                state.isLoading = false
                return handleAPIError(apiError)

            // MARK: - 알림 읽음 처리
            case let .markAsRead(id):
                state.lastFailedRequest = .markAsRead(id: id)
                return performMarkAsRead(id: id)

            case let .notificationReadSuccess(id):
                if let index = state.notifications.firstIndex(where: { $0.id == id }) {
                    state.notifications[index].isRead = true
                }
                return .none

            case let .notificationReadFailure(apiError):
                state.isLoading = false
                return handleAPIError(apiError)

            // MARK: - 재시도 로직
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }
                switch failed {
                case let .loadNotifications(page):
                    return performLoadNotifications(page: page)
                case let .markAsRead(id):
                    return performMarkAsRead(id: id)
                }

            default:
                return .none
            }
        }
    }
    
    func performLoadNotifications(page: Int) -> Effect<Action> {
        .run { send in
            do {
                let results = try await notificationsUseCase.execute(page: page, size: 20)
                await send(.notificationsSuccess(results))
            } catch {
                await send(.notificationsFailure(error as? APIError ?? .unknown))
            }
        }
    }

    func performMarkAsRead(id: Int) -> Effect<Action> {
        .run { send in
            do {
                try await notificationReadUseCase.execute(notificationId: id)
                await send(.notificationReadSuccess(id))
            } catch {
                await send(.notificationReadFailure(error as? APIError ?? .unknown))
            }
        }
    }

    func handleAPIError(_ apiError: APIError) -> Effect<Action> {
        switch apiError {
        case .networkError:
            return .send(.networkErrorPopup(.show))
        case .notFound:
            return .send(.serverError(.show(.notFound)))
        case .internalServer:
            return .send(.serverError(.show(.internalServer)))
        case .badGateway:
            return .send(.serverError(.show(.badGateway)))
        default:
            print(apiError.userMessage)
            return .none
        }
    }
}
