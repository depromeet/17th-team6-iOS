//
//  CertificateFriendsListFeature.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CertificateFriendsListFeature {
    @ObservableState
    struct State {
        var selectedDate: Date
        var friends: [CertificatedFriendViewModel] = []
        var friendsModel: [CertificatedFriend] = []
    }

    enum Action {
        case onAppear
        case setFriends([CertificatedFriend])
    }

    @Dependency(\.getFeedRepository) var feedRepository: FeedRepositoryProtocol

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    let dateString = state.selectedDate.toYYYYMMDD()
                    return .run { send in
                        do {
                            let worker = FeedWorker(repository: feedRepository)
                            let friends = try await worker.certificatedFriends(date: dateString)
                            await send(.setFriends(friends))
                        } catch {
                            print(#file, #line, "Error fetching certificated friends:", error)
                        }
                    }
                case let .setFriends(friends):
                    state.friendsModel = friends
                    state.friends = friends.map { CertificatedFriendsMapper.toViewModel($0) }
                    return .none
            }
        }
    }
}
