//
//  CertificationUserListFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CertificationUserListFeature {
    @ObservableState
    struct State: Equatable {
        var users: [SelfieUserViewState] = []
    }

    enum Action: Equatable {
        case backButtonTapped
        case userTapped(Int)

        enum Delegate: Equatable {
            case navigateToFriendProfile(userID: Int)
            case navigateToMyProfile
        }
        case delegate(Delegate)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .userTapped(userID):
                guard let user = state.users.first(where: { $0.id == userID }) else {
                    return .none
                }

                if user.isMe {
                    // 본인인 경우 My 프로필로 이동
                    return .send(.delegate(.navigateToMyProfile))
                } else {
                    // 친구인 경우 친구 프로필로 이동
                    return .send(.delegate(.navigateToFriendProfile(userID: userID)))
                }

            default: return .none
            }
        }
    }
}
