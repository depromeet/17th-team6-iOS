//
//  EnterBirthdateFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EnterBirthdateFeature {
    @ObservableState
    struct State: Equatable {
        var birthdateFrontNumber = ""
        var birthdateBackFirstDigit = ""
        var isBirthdateEntered = false
        var isBottomButtonEnabled: Bool {
            !birthdateFrontNumber.isEmpty && !birthdateBackFirstDigit.isEmpty
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        // 내부 동작
        case frontChanged(String)
        case backChanged(String)
        case confirmTapped
        
        // 상위 피처에서 처리
        case entered
        case invalidInputDetected(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
                
        Reduce { state, action in
            switch action {
                
            case .frontChanged(let front):
                state.birthdateFrontNumber = front
                return .none

            case .backChanged(let back):
                state.birthdateBackFirstDigit = back
                return .none

            case .confirmTapped:
                guard !state.birthdateFrontNumber.isEmpty,
                      !state.birthdateBackFirstDigit.isEmpty else {
                    return .send(.invalidInputDetected("입력한 정보가 올바르지 않아요."))
                }

                guard state.birthdateFrontNumber.count == 6,
                      let _ = Int(state.birthdateFrontNumber),
                      let first = Int(state.birthdateBackFirstDigit),
                      (1...4).contains(first) else {
                    return .send(.invalidInputDetected("입력한 정보가 올바르지 않아요."))
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyMMdd"
                if dateFormatter.date(from: state.birthdateFrontNumber) == nil {
                    return .send(.invalidInputDetected("입력한 정보가 올바르지 않아요."))
                }

                state.isBirthdateEntered = true
                return .send(.entered)
                
            default:
                return .none
            }
        }
    }
}
