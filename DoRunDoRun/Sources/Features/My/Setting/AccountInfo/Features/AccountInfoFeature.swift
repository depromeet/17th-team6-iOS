//
//  AccountInfoFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import ComposableArchitecture

@Reducer
struct AccountInfoFeature {
    @ObservableState
    struct State: Equatable {
        var phoneNumber: String = "010-7724-8020"
        var signUpDate: String = "2025.04.25"
    }

    enum Action: Equatable {
        // 내부 동작
        case onAppear
        
        // 상위 피처에서 처리
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            default:
                return .none
            }
        }
    }
}
