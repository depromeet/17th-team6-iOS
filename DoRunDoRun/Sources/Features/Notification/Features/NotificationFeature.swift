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
        var alertMessage: String? = nil
    }

    enum Action: Equatable {
        case toast(ToastFeature.Action)
        case onAppear
        case loadNotifications
        case notificationsSuccess([NotificationsResult])
        case markAsRead(Int)
        case notificationReadSuccess(Int)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - 알림 목록 요청
            case .onAppear:
                return .send(.loadNotifications)

            case .loadNotifications:
                return .run { send in
                    do {
                        let results = try await notificationsUseCase.execute(page: 0, size: 20)
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
                state.notifications = results.map { NotificationViewStateMapper.map(from: $0) }
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
