//
//  SettingWebFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/14/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingWebFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id = UUID()
        let urlString: String
        let title: String
    }

    enum Action: Equatable {
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .none
            }
        }
    }
}
