//
//  AgreeTermsWebFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/14/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AgreeTermsWebFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id = UUID()
        let url: URL?
    }

    enum Action: Equatable {
        case onAppear
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .backButtonTapped:
                return .none
            }
        }
    }
}
