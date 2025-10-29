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
        var enterPhoneNumber = EnterPhoneNumberFeature.State()
        var enterVerificationCode = EnterVerificationCodeFeature.State()
        var verifiedPhoneNumber: String? = nil  // 인증 완료 번호 저장
        var verifiedUntil: Date? = nil  // 인증 유효시간
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        // 하위 피처
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        case enterPhoneNumber(EnterPhoneNumberFeature.Action)
        case enterVerificationCode(EnterVerificationCodeFeature.Action)
        
        // 버튼 액션
        case bottomButtonTapped
        
        // 상위 피처에서 처리
        case completed(phoneNumber: String)
        case signupButtonTapped
        case findAccountButtonTapped
        case backButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }
        Scope(state: \.enterPhoneNumber, action: \.enterPhoneNumber) { EnterPhoneNumberFeature() }
        Scope(state: \.enterVerificationCode, action: \.enterVerificationCode) { EnterVerificationCodeFeature() }
        
        Reduce { state, action in
            switch action {
            case .enterPhoneNumber(.phoneNumberChanged):
                if state.enterPhoneNumber.isPhoneNumberEntered {
                    state.enterPhoneNumber.isPhoneNumberEntered = false
                    state.enterVerificationCode = .init()
                }
                return .none
                
            case .enterPhoneNumber(.entered):
                return .run { [phoneNumber = state.enterPhoneNumber.phoneNumber] send in
                    do {
                        try await sendSMSUseCase.execute(phoneNumber: phoneNumber)
                        await send(.enterVerificationCode(.timer(.start(seconds: 180))))
                    } catch {
                        await send(.toast(.show("인증번호 전송 실패")))
                    }
                }
                
            case .enterPhoneNumber(.invalidInputDetected(let message)):
                return .send(.toast(.show(message)))
                
            case .enterVerificationCode(.entered):
                return .run { [mode = state.mode,
                               phoneNumber = state.enterPhoneNumber.phoneNumber,
                               code = state.enterVerificationCode.verificationCode] send in
                    do {
                        let result = try await verifySMSUseCase.execute(phoneNumber: phoneNumber, verificationCode: code)
                        
                        // 인증 성공시 저장
                        await send(.binding(.set(\.verifiedPhoneNumber, phoneNumber)))
                        await send(.binding(.set(\.verifiedUntil, Date().addingTimeInterval(180))))

                        
                        // 가입/로그인 모드에 따라 분기 처리
                        if result.isExistingUser {
                            if mode == .login {
                                await send(.completed(phoneNumber: phoneNumber))
                            } else {
                                await send(.popup(.show(
                                    action: .findAccount,
                                    title: "이미 가입된 번호예요.\n계정을 찾으시겠어요?",
                                    message: nil,
                                    actionTitle: "계정찾기",
                                    cancelTitle: "닫기"
                                )))
                            }
                        } else {
                            if mode == .signup {
                                await send(.completed(phoneNumber: phoneNumber))
                            } else {
                                await send(.popup(.show(
                                    action: .signup,
                                    title: "아직 가입하지 않은 번호예요.\n회원가입을 진행할까요?",
                                    message: nil,
                                    actionTitle: "가입하기",
                                    cancelTitle: "닫기"
                                )))
                            }
                        }
                    } catch {
                        await send(.toast(.show("인증 실패")))
                    }
                }
                
            case .enterVerificationCode(.invalidInputDetected(let message)):
                return .send(.toast(.show(message)))
                
            case .bottomButtonTapped:
                if let verified = state.verifiedPhoneNumber,
                   let expires = state.verifiedUntil {
                    if Date() < expires {
                        // 아직 유효 → 완료로 진행
                        return .send(.completed(phoneNumber: verified))
                    } else {
                        // 만료됨 → 토스트 출력
                        return .send(.toast(.show("인증 시간이 만료되었어요.")))
                    }
                }
                
                if !state.enterPhoneNumber.isPhoneNumberEntered {
                    return .send(.enterPhoneNumber(.confirmTapped))
                }
                if !state.enterVerificationCode.isVerificationCodeEntered {
                    return .send(.enterVerificationCode(.confirmTapped))
                }
                return .none
                
            default:
                return .none
            }
        }
    }
}
