//
//  EnterVerificationCodeFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import ComposableArchitecture

@Reducer
struct EnterVerificationCodeFeature {
    @ObservableState
    struct State: Equatable {
        var timer = TimerFeature.State()
        var verificationCode = ""
        var isVerificationCodeEntered = false
        var isBottomButtonEnabled: Bool {
            verificationCode.count == 6
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        // 하위 피처
        case timer(TimerFeature.Action)
        
        // 내부 동작
        case codeChanged(String)
        case resendTapped
        case confirmTapped
        
        // 상위 피처에서 처리
        case entered
        case invalidInputDetected(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.timer, action: \.timer) { TimerFeature() }

        Reduce { state, action in
            switch action {

            case .codeChanged(let code):
                state.verificationCode = code
                return .none

            case .resendTapped:
                state.verificationCode = ""
                return .send(.timer(.restart(seconds: 180)))

            case .confirmTapped:
                guard state.timer.isActive else {
                    return .send(.invalidInputDetected("인증 시간이 만료되었어요."))
                }

                guard state.verificationCode.count == 6 else {
                    return .send(.invalidInputDetected("인증번호가 올바르지 않아요."))
                }

                // 서버 검증 필요, 현재는 하드코딩 비교
                guard state.verificationCode == "123456" else {
                    return .send(.invalidInputDetected("인증번호가 올바르지 않아요."))
                }

                state.isVerificationCodeEntered = true
                return .send(.entered)

            default:
                return .none
            }
        }
    }
}
