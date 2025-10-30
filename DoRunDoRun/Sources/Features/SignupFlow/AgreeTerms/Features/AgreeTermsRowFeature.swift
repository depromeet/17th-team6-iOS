//
//  AgreeTermsRowFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/25/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AgreeTermsRowFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: Int
        let title: String
        let isEssential: Bool
        var isOn: Bool = false
    }

    enum Action: Equatable {
        // 내부 동작
        case toggle(Bool)
        case chevronTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .toggle(isOn):
                state.isOn = isOn
                return .none

            case .chevronTapped:
                return .none
            }
        }
    }
}
