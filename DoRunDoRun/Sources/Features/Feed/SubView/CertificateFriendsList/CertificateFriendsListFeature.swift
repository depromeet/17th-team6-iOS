//
//  CertificateFriendsListFeature.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import ComposableArchitecture

@Reducer
struct CertificateFriendsListFeature {
    @ObservableState
    struct State {
        var friends: [FriendCertificate] = []
    }

    enum Action {
        case onAppear
        case setFriends([FriendCertificate])
    }

    @Dependency(\.getFeedRepository) var feedRepository: FeedRepositoryProtocol

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    return .run { send in
                        // TODO: 여기에 API 호출 해야 함.
                        let worker = FeedWorker(repository: feedRepository)
                    }
                case let .setFriends(friends):
                    state.friends = friends
                    return .none
            }
        }
    }
}

struct FriendCertificate {
    let name: String
    let daysAgo: Int
}
