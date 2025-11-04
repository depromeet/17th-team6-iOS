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
        var notifications: [NotificationViewState] = []
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true
    }

    enum Action: Equatable {
        case toast(ToastFeature.Action)
        case onAppear
        case loadNotifications(page: Int)
        case notificationsSuccess([NotificationsResult])
        case markAsRead(Int)
        case notificationReadSuccess(Int)
        case loadNextPageIfNeeded(currentItem: NotificationViewState?)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - 알림 목록 요청
            case .onAppear:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .send(.loadNotifications(page: 0))

            case let .loadNotifications(page):
                state.isLoading = true
                return .run { [page] send in
                    do {
                        let results = try await notificationsUseCase.execute(page: page, size: 20)
                        await send(.notificationsSuccess(results))
                    } catch {
                        if let apiError = error as? APIError {
                            switch apiError {
                            case .unauthorized:
                                await send(.toast(.show("세션이 만료되었습니다. 다시 로그인해주세요.")))
                            default:
                                await send(.toast(.show(apiError.userMessage)))
                            }
                        } else {
                            await send(.toast(.show(APIError.unknown.userMessage)))
                        }
                    }
                }

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



            // MARK: - 알림 읽음 처리
            case let .markAsRead(id):
                return .run { send in
                    do {
                        try await notificationReadUseCase.execute(notificationId: id)
                        await send(.notificationReadSuccess(id))
                    } catch {
                        if let apiError = error as? APIError {
                            switch apiError {
                            case .unauthorized:
                                await send(.toast(.show("세션이 만료되었습니다. 다시 로그인해주세요.")))
                            case .notFound:
                                await send(.toast(.show("해당 알림을 찾을 수 없습니다.")))
                            default:
                                await send(.toast(.show(apiError.userMessage)))
                            }
                        } else {
                            await send(.toast(.show(APIError.unknown.userMessage)))
                        }
                    }
                }

            case let .notificationReadSuccess(id):
                if let index = state.notifications.firstIndex(where: { $0.id == id }) {
                    state.notifications[index].isRead = true
                }
                return .none
                
            default:
                return .none
            }
        }
    }
}
