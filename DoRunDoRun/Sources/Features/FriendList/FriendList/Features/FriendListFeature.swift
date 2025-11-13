//
//  FriendListFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation
import ComposableArchitecture
import UIKit

@Reducer
struct FriendListFeature {
    @Dependency(\.friendListUseCase) var friendListUseCase
    @Dependency(\.friendDeleteUseCase) var friendDeleteUseCase
    @Dependency(\.myFriendCodeUseCase) var myFriendCodeUseCase

    @ObservableState
    struct State: Equatable {
        @Presents var friendCodeInput: FriendCodeInputFeature.State?

        var toast = ToastFeature.State()
        var popup = PopupFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        
        var friends: [FriendRunningStatusViewState] = []
        var hasAppearedOnce = false
        var needsReloadAfterFriendAdd = false
        
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true

        enum FailedRequestType: Equatable {
            case loadFriends(page: Int)
            case delete(friendID: Int)
            case copyMyCode
        }
        var lastFailedRequest: FailedRequestType? = nil
    }

    enum Action: Equatable {
        case friendCodeInput(PresentationAction<FriendCodeInputFeature.Action>)
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        case onAppear
        case loadFriends(page: Int)
        case loadFriendsSuccess([FriendRunningStatus])
        case loadNextPageIfNeeded(currentItem: FriendRunningStatusViewState?)
        case loadFriendsFailure(APIError)
        
        case showDeletePopup(Int)
        case confirmDelete(Int)
        case deleteSuccess(FriendDeleteResult)
        case deleteFailure(APIError)
        
        case copyMyCodeButtonTapped
        case copyMyCodeSuccess(String)
        case copyMyCodeFailure(APIError)
        
        case friendCodeInputButtonTapped
        case backButtonTapped
        
        enum Delegate: Equatable {
            case friendAdded
        }
        case delegate(Delegate)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - Lifecycle
            case .onAppear:
                // 처음 들어올 때
                if !state.hasAppearedOnce {
                    state.hasAppearedOnce = true
                    return .send(.loadFriends(page: 0))
                }
                
                // 친구 추가 후 돌아왔을 때
                if state.needsReloadAfterFriendAdd {
                    state.needsReloadAfterFriendAdd = false
                    return .send(.loadFriends(page: 0))
                }
                
                // 그 외의 경우 (단순 복귀)
                return .none

            // MARK: - Load Friends
            case let .loadFriends(page):
                state.isLoading = true
                state.lastFailedRequest = .loadFriends(page: page)
                return performLoadFriends(page: page)

            case let .loadFriendsSuccess(friends):
                state.isLoading = false
                if friends.isEmpty {
                    state.hasNextPage = false
                } else {
                    let filtered = friends.filter { !$0.isMe }
                    let mapped = filtered.map { FriendRunningStatusViewStateMapper.map(from: $0) }
                    if state.currentPage == 0 {
                        // 첫 페이지
                        state.friends = mapped
                    } else {
                        // 다음 페이지 append
                        state.friends.append(contentsOf: mapped)
                    }
                    state.currentPage += 1
                }
                return .none
                
            case let .loadNextPageIfNeeded(currentItem):
                guard let currentItem else { return .none }
                guard !state.isLoading && state.hasNextPage else { return .none }

                // 데이터 개수에 따라 thresholdIndex를 안전하게 계산
                let threshold = max(state.friends.count - 5, 0)
                if let currentIndex = state.friends.firstIndex(where: { $0.id == currentItem.id }),
                   currentIndex >= threshold {
                    let nextPage = state.currentPage + 1
                    print("[DEBUG] 다음 페이지 요청: \(nextPage)")
                    return .send(.loadFriends(page: nextPage))
                }
                return .none

            case let .loadFriendsFailure(apiError):
                state.isLoading = false
                return handleAPIError(apiError)

            // MARK: - Delete Flow
            case let .showDeletePopup(friendID):
                return .send(
                    .popup(.show(
                        action: .deleteFriend(friendID),
                        title: "친구 삭제",
                        message: "선택된 친구가 친구목록에서 사라져요.\n정말로 삭제하시겠어요?",
                        actionTitle: "삭제",
                        cancelTitle: "취소"
                    ))
                )

            case let .confirmDelete(friendID):
                state.lastFailedRequest = .delete(friendID: friendID)
                return performDelete(friendID: friendID)

            case let .deleteFailure(apiError):
                state.isLoading = false
                return handleAPIError(apiError)

            case let .deleteSuccess(result):
                let names = result.deletedFriends.map(\.nickname).joined(separator: ", ")
                return .merge(
                    .send(.loadFriends(page: 0)),
                    .send(.toast(.show("'\(names)' 친구가 삭제되었어요.")))
                )

            // MARK: - Copy Code
            case .copyMyCodeButtonTapped:
                state.lastFailedRequest = .copyMyCode
                return performCopyMyCode()

            case let .copyMyCodeFailure(apiError):
                state.isLoading = false
                return handleAPIError(apiError)

            case let .copyMyCodeSuccess(code):
                UIPasteboard.general.string = code
                return .send(.toast(.show("클립보드에 내 코드가 복사되었어요!")))

            // MARK: - Friend Code Input
            case .friendCodeInputButtonTapped:
                state.friendCodeInput = FriendCodeInputFeature.State()
                return .none
                
            case let .friendCodeInput(.presented(.submitSuccess(friendCode))):
                state.friendCodeInput = nil
                state.needsReloadAfterFriendAdd = true
                return .merge(
                    .send(.delegate(.friendAdded)),
                    .send(.toast(.show("'\(friendCode.nickname)' 친구가 추가되었어요!")))
                )
                
            case .friendCodeInput(.presented(.backButtonTapped)):
                state.friendCodeInput = nil
                return .none

            // MARK: - Retry Handling
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }
                switch failed {
                case let .loadFriends(page):
                    return performLoadFriends(page: page)
                case let .delete(friendID):
                    return performDelete(friendID: friendID)
                case .copyMyCode:
                    return performCopyMyCode()
                }

            default:
                return .none
            }
        }
        .ifLet(\.$friendCodeInput, action: \.friendCodeInput) {
            FriendCodeInputFeature()
        }
    }
    
    func performLoadFriends(page: Int) -> Effect<Action> {
        .run { send in
            do {
                let friends = try await friendListUseCase.execute(page: page, size: 20)
                await send(.loadFriendsSuccess(friends))
            } catch {
                await send(.loadFriendsFailure(error as? APIError ?? .unknown))
            }
        }
    }

    func performDelete(friendID: Int) -> Effect<Action> {
        .run { send in
            do {
                let result = try await friendDeleteUseCase.execute(ids: [friendID])
                await send(.deleteSuccess(result))
            } catch {
                await send(.deleteFailure(error as? APIError ?? .unknown))
            }
        }
    }

    func performCopyMyCode() -> Effect<Action> {
        .run { send in
            do {
                let result = try await myFriendCodeUseCase.execute()
                await send(.copyMyCodeSuccess(result.code))
            } catch {
                await send(.copyMyCodeFailure(error as? APIError ?? .unknown))
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
