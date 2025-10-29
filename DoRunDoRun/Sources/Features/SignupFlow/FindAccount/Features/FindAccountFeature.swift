//
//  FindAccountView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import ComposableArchitecture

enum Field: Equatable {
    case phoneNumber, name, nickname, birthdate, verificationCode, clear
}

@Reducer
struct FindAccountFeature {
    @ObservableState
    struct State: Equatable {
        var focusField: Field? = .phoneNumber
        var toast = ToastFeature.State()
        var phoneNumberInput = EnterPhoneNumberFeature.State()
        var carrierSelection = SelectCarrierFeature.State()
        var isCarrierSelectionSheetPresented = false
        var isCarrierSelected = false
        var carrier = ""
        var nameInput = EnterNameFeature.State()
        var birthdateInput = EnterBirthdateFeature.State()
        var termsAgreement = AgreeTermsFeature.State(type: .findAccount)
        var isTermsAgreementSheetPresented = false
        var isTermsAgreed = false
        var verificationCodeInput = EnterVerificationCodeFeature.State()
        
        var isBottomButtonEnabled: Bool {
            if !phoneNumberInput.isPhoneNumberEntered {
                return phoneNumberInput.isBottomButtonEnabled
            } else if !isCarrierSelected {
                return true
            } else if !nameInput.isNameEntered {
                return nameInput.isBottomButtonEnabled
            } else if !birthdateInput.isBirthdateEntered {
                return birthdateInput.isBottomButtonEnabled
            } else if !isTermsAgreed {
                return true
            } else {
                return verificationCodeInput.isBottomButtonEnabled
            }
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        // 하위 피처
        case toast(ToastFeature.Action)
        case phoneNumberInput(EnterPhoneNumberFeature.Action)
        case carrierSelection(SelectCarrierFeature.Action)
        case nameInput(EnterNameFeature.Action)
        case birthdateInput(EnterBirthdateFeature.Action)
        case termsAgreement(AgreeTermsFeature.Action)
        case verificationCodeInput(EnterVerificationCodeFeature.Action)
        
        // 내부 동작
        case carrierFieldTapped
        case dismissCarrierSheet
        case dismissTermsAgreementSheet
        
        // 버튼 액션
        case bottomButtonTapped
        
        // 상위 피처에서 처리
        case completed
        case backButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.phoneNumberInput, action: \.phoneNumberInput) { EnterPhoneNumberFeature() }
        Scope(state: \.nameInput, action: \.nameInput) { EnterNameFeature() }
        Scope(state: \.birthdateInput, action: \.birthdateInput) { EnterBirthdateFeature() }
        Scope(state: \.verificationCodeInput, action: \.verificationCodeInput) { EnterVerificationCodeFeature() }
        Scope(state: \.carrierSelection, action: \.carrierSelection) { SelectCarrierFeature() }
        Scope(state: \.termsAgreement, action: \.termsAgreement) { AgreeTermsFeature() }
        
        Reduce { state, action in
            switch action {
                
            // MARK: - 입력 변화 관련 액션
            case .phoneNumberInput(.phoneNumberChanged),
                 .nameInput(.nameChanged),
                 .birthdateInput(.frontChanged),
                 .birthdateInput(.backChanged):
                resetTermsIfNeeded(&state)
                return .none
                
            // MARK: - 휴대폰 번호 입력 완료
            case .phoneNumberInput(.entered):
                state.isCarrierSelectionSheetPresented = true
                state.focusField = .clear
                return .none
                
            case .phoneNumberInput(.invalidInputDetected(let message)):
                return .send(.toast(.show(message)))
                
            // MARK: - 통신사 선택 관련
            case .carrierFieldTapped:
                state.isCarrierSelectionSheetPresented = true
                state.focusField = .clear
                return .none
                
            case .carrierSelection(.carrierTapped(let carrier)):
                state.isCarrierSelectionSheetPresented = false
                state.isCarrierSelected = true
                state.carrier = carrier
                state.focusField = .name
                resetTermsIfNeeded(&state)
                return .none
                
            case .carrierSelection(.dismissRequested):
                state.isCarrierSelectionSheetPresented = false
                return .none
                
            // MARK: - 이름 입력 관련
            case .nameInput(.entered):
                state.focusField = .birthdate
                return .none
                
            case .nameInput(.invalidInputDetected(let message)):
                return .send(.toast(.show(message)))
                
            // MARK: - 생년월일 입력 관련
            case .birthdateInput(.entered):
                state.isTermsAgreementSheetPresented = true
                state.focusField = .clear
                return .none
                
            case .birthdateInput(.invalidInputDetected(let message)):
                return .send(.toast(.show(message)))
                
            // MARK: - 약관 동의 관련
            case .termsAgreement(.completed):
                state.isTermsAgreementSheetPresented = false
                state.isTermsAgreed = true
                state.focusField = .verificationCode
                return .send(.verificationCodeInput(.timer(.start(seconds: 180))))
                
            case .termsAgreement(.dismissRequested):
                state.isTermsAgreementSheetPresented = false
                return .none
                
            // MARK: - 인증번호 입력 관련
            case .verificationCodeInput(.entered):
                return .send(.completed)
                
            case .verificationCodeInput(.invalidInputDetected(let message)):
                return .send(.toast(.show(message)))

            // MARK: - 하단 버튼
            case .bottomButtonTapped:
                if !state.phoneNumberInput.isPhoneNumberEntered {
                    return .send(.phoneNumberInput(.confirmTapped))
                }
                if !state.isCarrierSelected {
                    state.focusField = .clear
                    state.isCarrierSelectionSheetPresented = true
                    return .none
                }
                if !state.nameInput.isNameEntered {
                    return .send(.nameInput(.confirmTapped))
                }
                if !state.birthdateInput.isBirthdateEntered {
                    return .send(.birthdateInput(.confirmTapped))
                }
                if !state.isTermsAgreed {
                    state.focusField = .clear
                    state.isTermsAgreementSheetPresented = true
                    return .none
                }
                if !state.verificationCodeInput.isVerificationCodeEntered {
                    return .send(.verificationCodeInput(.confirmTapped))
                }
                return .none
                
            default:
                return .none
            }
        }
    }
}

// MARK: - Private Helpers
private func resetTermsIfNeeded(_ state: inout FindAccountFeature.State) {
    if state.isTermsAgreed {
        state.termsAgreement = .init(type: .findAccount)
        state.isTermsAgreementSheetPresented = false
        state.isTermsAgreed = false
        state.verificationCodeInput = .init()
    }
}
