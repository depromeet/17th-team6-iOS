//
//  NetworkErrorPopupFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import ComposableArchitecture

@Reducer
struct NetworkErrorPopupFeature {
    @ObservableState
    struct State: Equatable {
        var isVisible = false
    }

    enum Action: Equatable {
        case show
        case hide
        case retryButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .show:
                state.isVisible = true
                return .none

            case .hide:
                state.isVisible = false
                return .none
                
            case .retryButtonTapped:
                state.isVisible = false
                // 상위 Feature에서 처리
                return .none
            }
        }
    }
}
