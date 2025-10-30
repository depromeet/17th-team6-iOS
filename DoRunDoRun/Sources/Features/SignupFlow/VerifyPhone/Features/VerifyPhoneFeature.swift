//
//  VerifyPhoneFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import Foundation

import ComposableArchitecture

enum PhoneAuthMode: Equatable { case signup, login }

@Reducer
struct VerifyPhoneFeature {
    @Dependency(\.authSendSMSUseCase) var sendSMSUseCase
    @Dependency(\.authVerifySMSUseCase) var verifySMSUseCase
    
    @ObservableState
    struct State: Equatable {
        var mode: PhoneAuthMode
        var toast = ToastFeature.State()
        var popup = PopupFeature.State()
        var timer = TimerFeature.State()
        
        var phoneNumber = ""
        var verificationCode = ""
        var isPhoneNumberEntered = false
        var isVerificationCodeEntered = false
        var isResendButtonDisabled = false
        
        var isBottomButtonEnabled: Bool {
            if !isPhoneNumberEntered {
                return !phoneNumber.isEmpty && phoneNumber.filter(\.isNumber).count == 11
            } else {
                return verificationCode.count == 6
            }
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        case timer(TimerFeature.Action)
        
        // 입력/버튼 액션
        case phoneNumberChanged(String)
        case verificationCodeChanged(String)
        case bottomButtonTapped
        case resendTapped
        
        // 상위로 전달
        case completed(phoneNumber: String)
        case signupButtonTapped
        case findAccountButtonTapped
        case backButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }
        Scope(state: \.timer, action: \.timer) { TimerFeature() }
        
        Reduce { state, action in
            switch action {
            // MARK: 전화번호 입력
            case .phoneNumberChanged(let newValue):
                state.phoneNumber = newValue.formattedPhoneNumber()
                return .none
                
            // MARK: 인증번호 입력
            case .verificationCodeChanged(let code):
                state.verificationCode = code
                return .none
                
            case .bottomButtonTapped:
                // MARK: 인증번호 전송
                if !state.isPhoneNumberEntered {
                    let clean = state.phoneNumber.filter(\.isNumber)
                    guard clean.count == 11 else { return .send(.toast(.show("올바른 휴대폰 번호를 입력해주세요."))) }
                    state.isPhoneNumberEntered = true
                    
                    return .run { [phoneNumber = state.phoneNumber] send in
                        do {
                            try await sendSMSUseCase.execute(phoneNumber: phoneNumber)
                            await send(.timer(.start(seconds: 180)))
                        } catch {
                            if let apiError = error as? APIError {
                                switch apiError {
                                case .badRequest:
                                    await send(.toast(.show("올바른 휴대폰 번호를 입력해주세요.")))
                                case .tooManyRequests:
                                    await send(.toast(.show("인증번호 전송은 하루 5회까지만 가능해요.")))
                                default:
                                    await send(.toast(.show(apiError.userMessage)))
                                }
                            } else {
                                await send(.toast(.show("인증번호 전송 실패")))
                            }
                        }
                    }
                }
                
                // MARK: 인증번호 확인
                guard state.verificationCode.count == 6 else { return .send(.toast(.show("인증번호 6자리를 모두 입력해주세요."))) }
                
                return .run { [phoneNumber = state.phoneNumber,
                               code = state.verificationCode,
                               mode = state.mode] send in
                    do {
                        let response = try await verifySMSUseCase.execute(phoneNumber: phoneNumber, verificationCode: code)
                        if response.isExistingUser {
                            switch mode {
                            case .login:
                                // 로그인 플로우 → 기존 회원 로그인 완료
                                await send(.completed(phoneNumber: phoneNumber))
                            case .signup:
                                // 회원가입 중인데 기존 회원 → 계정찾기 유도
                                await send(.popup(.show(
                                    action: .findAccount,
                                    title: "이미 가입된 번호예요.\n계정을 찾으시겠어요?",
                                    actionTitle: "계정찾기",
                                    cancelTitle: "닫기"
                                )))
                            }
                        } else {
                            switch mode {
                            case .signup:
                                // 신규 회원 → 회원가입 진행
                                await send(.completed(phoneNumber: phoneNumber))
                            case .login:
                                // 로그인 중인데 신규회원 → 회원가입 유도
                                await send(.popup(.show(
                                    action: .signup,
                                    title: "아직 가입하지 않은 번호예요.\n회원가입을 진행할까요?",
                                    actionTitle: "가입하기",
                                    cancelTitle: "닫기"
                                )))
                            }
                        }
                    } catch {
                        if let apiError = error as? APIError {
                            switch apiError {
                            case .badRequest:
                                await send(.toast(.show("인증번호가 올바르지 않아요.")))
                            case .unprocessableEntity:
                                await send(.toast(.show("인증시간이 만료되었어요.")))
                            default:
                                await send(.toast(.show(apiError.userMessage)))
                            }
                        } else {
                            await send(.toast(.show("인증에 실패했어요.")))
                        }
                    }
                }
                
            // MARK: 인증번호 재전송
            case .resendTapped:
                state.isResendButtonDisabled = true
                state.verificationCode = ""
                
                return .merge(
                    .run { [phoneNumber = state.phoneNumber] send in
                        do {
                            try await sendSMSUseCase.execute(phoneNumber: phoneNumber)
                            await send(.timer(.restart(seconds: 180)))
                        } catch {
                            if let apiError = error as? APIError {
                                switch apiError {
                                case .badRequest:
                                    await send(.toast(.show("올바른 휴대폰 번호를 입력해주세요.")))
                                case .tooManyRequests:
                                    await send(.toast(.show("인증번호 전송은 하루 5회까지만 가능해요.")))
                                default:
                                    await send(.toast(.show(apiError.userMessage)))
                                }
                            } else {
                                await send(.toast(.show("인증번호 재전송 실패")))
                            }
                        }
                    },
                    
                    .run { send in
                        try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
                        await send(.binding(.set(\.isResendButtonDisabled, false)))
                    }
                )
                
            default:
                return .none
            }
        }
    }
}
