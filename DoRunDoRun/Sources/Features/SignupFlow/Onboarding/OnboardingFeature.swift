//
//  OnboardingFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var currentPage = 0
        let totalPages = 3
    }

    enum Action: Equatable {
        case nextPage
        case previousPage
        case pageChanged(Int)
        case signupButtonTapped
        case loginButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextPage:
                if state.currentPage < state.totalPages - 1 {
                    state.currentPage += 1
                }
                return .none

            case .previousPage:
                if state.currentPage > 0 {
                    state.currentPage -= 1
                }
                return .none

            case let .pageChanged(index):
                state.currentPage = index
                return .none

            case .signupButtonTapped:
                // TODO: 다음 화면 전환 연결
                return .none
            case .loginButtonTapped:
                // TODO: 다음 화면 전환 연결
                return .none
            }
        }
    }
}
