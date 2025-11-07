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
    struct State {
        var path = StackState<Path.State>()
        
        var toast = ToastFeature.State()
        var popup = PopupFeature.State()
        
        var friends: [FriendRunningStatusViewState] = []
        var hasAppearedOnce = false              // 최초 진입 감지
        var needsReloadAfterFriendAdd = false    // 친구 추가 후 복귀 시 갱신 여부
    }

    enum Action {
        case path(StackActionOf<Path>)
        
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        
        case onAppear
        case loadFriends
        case loadFriendsSuccess([FriendRunningStatus])
        
        case showDeletePopup(Int)
        case confirmDelete(Int)
        case deleteSuccess
        
        case copyMyCodeButtonTapped
        case copyMyCodeSuccess(String)
        
        case friendCodeInputButtonTapped
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }
        
        Reduce { state, action in
            switch action {

            // MARK: - Lifecycle
            case .onAppear:
                // 처음 들어올 때
                if !state.hasAppearedOnce {
                    state.hasAppearedOnce = true
                    return .send(.loadFriends)
                }
                
                // 친구 추가 후 돌아왔을 때
                if state.needsReloadAfterFriendAdd {
                    state.needsReloadAfterFriendAdd = false
                    return .send(.loadFriends)
                }
                
                // 그 외의 경우 (단순 복귀)
                return .none

            // MARK: - Load Friends
            case .loadFriends:
                return .run { send in
                    do {
                        let friends = try await friendListUseCase.excute(page: 0, size: 20)
                        await send(.loadFriendsSuccess(friends))
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.userMessage)
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }

            case let .loadFriendsSuccess(friends):
                state.friends = friends.map { FriendRunningStatusViewStateMapper.map(from: $0) }
                return .none

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
                return .run { send in
                    do {
                        try await friendDeleteUseCase.execute(ids: [friendID])
                        await send(.deleteSuccess)
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.userMessage)
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }

            case .deleteSuccess:
                return .send(.loadFriends)
                
            case .copyMyCodeButtonTapped:
                return .run { send in
                    do {
                        let result = try await myFriendCodeUseCase.execute()
                        await send(.copyMyCodeSuccess(result.code))
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.userMessage)
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }

            case let .copyMyCodeSuccess(code):
                UIPasteboard.general.string = code
                return .send(.toast(.show("클립보드에 내 코드가 복사되었어요!")))
                
            case .friendCodeInputButtonTapped:
                state.path.append(.friendCodeInput(FriendCodeInputFeature.State()))
                return .none

            case .path(.element(id: _, action: .friendCodeInput(.submitSuccess))):
                state.path.removeAll()
                state.needsReloadAfterFriendAdd = true
                return .send(.toast(.show("친구가 추가되었어요!")))
                
            case .path(.element(id: _, action: .friendCodeInput(.backButtonTapped))):
                state.path.removeLast()
                return .none

            default:
                return .none

            }
        }
        .forEach(\.path, action: \.path)
    }
    
    @Reducer
    enum Path {
        case friendCodeInput(FriendCodeInputFeature)
    }
}
