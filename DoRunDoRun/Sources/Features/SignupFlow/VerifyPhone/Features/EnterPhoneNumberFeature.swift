//
//  EnterPhoneNumberFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import ComposableArchitecture

@Reducer
struct EnterPhoneNumberFeature {
    @ObservableState
    struct State: Equatable {
        var phoneNumber = ""
        var isPhoneNumberEntered = false
        var isBottomButtonEnabled: Bool {
            !phoneNumber.isEmpty && phoneNumber.filter(\.isNumber).count == 11
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case phoneNumberChanged(String)
        case confirmTapped
        case entered(String)
        case invalidInputDetected(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .phoneNumberChanged(let newValue):
                state.phoneNumber = newValue.formattedPhoneNumber()
                return .none

            case .confirmTapped:
                let clean = state.phoneNumber.filter(\.isNumber)
                
                guard clean.count == 11 else {
                    return .send(.invalidInputDetected("올바른 휴대폰 번호를 입력해주세요."))
                }

                state.isPhoneNumberEntered = true
                return .send(.entered(state.phoneNumber))
                
            case .entered:
                return .none

            default:
                return .none
            }
        }
    }
}
