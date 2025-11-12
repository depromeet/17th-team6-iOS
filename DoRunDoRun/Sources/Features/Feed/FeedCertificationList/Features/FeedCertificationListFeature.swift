//
//  FeedCertificationListFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FeedCertificationListFeature {
    @ObservableState
    struct State: Equatable {
        var users: [SelfieUserViewState] = []
    }

    enum Action: Equatable {
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
}
