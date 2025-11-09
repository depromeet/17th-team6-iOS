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
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: 친구 목록 데이터 로드
                state.friends = [
                    FriendCertificate(name: "비락식혜", daysAgo: 2),
                    FriendCertificate(name: "버터꿀빵주", daysAgo: 3),
                    FriendCertificate(name: "불닭마요", daysAgo: 3),
                    FriendCertificate(name: "날뽕마", daysAgo: 3),
                    FriendCertificate(name: "와사비맛팝콘", daysAgo: 3),
                    FriendCertificate(name: "차가운녹차", daysAgo: 3)
                ]
                return .none
            }
        }
    }
}

struct FriendCertificate {
    let name: String
    let daysAgo: Int
}
