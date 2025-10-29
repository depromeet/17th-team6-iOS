//
//  EnterNameFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import ComposableArchitecture

@Reducer
struct EnterNameFeature {
    @ObservableState
    struct State: Equatable {
        var name = ""
        var isNameEntered = false
        var isBottomButtonEnabled: Bool {
            !name.isEmpty
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        // 내부 동작
        case nameChanged(String)
        case confirmTapped
        
        // 상위 피처에서 처리
        case entered
        case invalidInputDetected(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
                
        Reduce { state, action in
            switch action {
                
            case .nameChanged(let newName):
                state.name = newName
                return .none

            case .confirmTapped:
                guard !state.name.isEmpty else {
                    return .send(.invalidInputDetected("입력한 정보가 올바르지 않아요."))
                }

                state.isNameEntered = true
                return .send(.entered)

            default:
                return .none
            }
        }
    }
}
