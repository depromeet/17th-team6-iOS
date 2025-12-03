//
//  ServerErrorFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import ComposableArchitecture

@Reducer
struct ServerErrorFeature {
    @ObservableState
    struct State: Equatable {
        var isVisible = false
        var serverErrorType: ServerErrorType? = nil
    }

    enum Action: Equatable {
        case show(ServerErrorType)
        case hide
        case retryButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .show(serverErrorType):
                state.isVisible = true
                state.serverErrorType = serverErrorType
                return .none

            case .hide:
                state.isVisible = false
                state.serverErrorType = nil
                return .none
                
            case .retryButtonTapped:
                state.isVisible = false
                state.serverErrorType = nil
                // 상위 Feature에서 처리
                return .none
            }
        }
    }
}
