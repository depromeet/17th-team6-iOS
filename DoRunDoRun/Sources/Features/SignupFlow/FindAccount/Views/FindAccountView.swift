//
//  FindAccountView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI
import ComposableArchitecture

struct FindAccountView: View {
    @Perception.Bindable var store: StoreOf<FindAccountFeature>
    @FocusState private var focusedField: Field?
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        titleSection
                        inputSections
                        Spacer()
                    }
                    .padding(.bottom, 76) // 버튼 높이 확보
                    .padding(.horizontal, 20)
                }
                .task { focusedField = .phoneNumber } // 시작 시 포커스
                .focused($focusedField, equals: .phoneNumber)
                .focused($focusedField, equals: .name)
                .focused($focusedField, equals: .birthdate)
                .focused($focusedField, equals: .verificationCode)
                .onChange(of: store.focusField) { newValue in
                    switch newValue {
                    case .phoneNumber: focusedField = .phoneNumber
                    case .name: focusedField = .name
                    case .birthdate: focusedField = .birthdate
                    case .verificationCode: focusedField = .verificationCode
                    case .clear: focusedField = nil
                    default: focusedField = nil
                    }
                }

                toastAndButtonSection
                sheetOverlaySection
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        store.send(.backButtonTapped)
                    } label: {
                        Image(.arrowLeft, size: .medium)
                            .renderingMode(.template)
                            .foregroundColor(.gray800)
                    }
                }
            }
        }
    }
}

// MARK: - Title
private extension FindAccountView {
    @ViewBuilder
    var titleSection: some View {
        TypographyText(
            text: titleText,
            style: .h2_700,
            alignment: .left
        )
        .padding(.top, 16)
        .transition(.opacity.combined(with: .slide))
    }

    var titleText: String {
        if !store.phoneNumberInput.isPhoneNumberEntered {
            return "휴대폰 번호를 입력해주세요."
        } else if !store.isCarrierSelected {
            return "통신사를 선택해주세요."
        } else if !store.nameInput.isNameEntered {
            return "이름을 입력해주세요."
        } else if !store.birthdateInput.isBirthdateEntered {
            return "생년월일/성별을 입력해주세요."
        } else if !store.isTermsAgreed {
            return "약관에 동의해주세요."
        } else {
            return "인증번호 6자리를 입력해주세요."
        }
    }
}

// MARK: - Input
private extension FindAccountView {
    @ViewBuilder
    var inputSections: some View {
        if store.isTermsAgreed {
            EnterVerificationCodeView(store: store.scope(state: \.verificationCodeInput, action: \.verificationCodeInput))
            .focused($focusedField, equals: .verificationCode)
        }
        
        if store.nameInput.isNameEntered {
            EnterBirthdateView(store: store.scope(state: \.birthdateInput, action: \.birthdateInput))
            .focused($focusedField, equals: .birthdate)
        }
        
        if store.isCarrierSelected {
            EnterNameView(store: store.scope(state: \.nameInput, action: \.nameInput))
            .focused($focusedField, equals: .name)
        }
        
        if store.phoneNumberInput.isPhoneNumberEntered {
            InputField(
                label: store.isCarrierSelected ? "통신사" : nil,
                placeholder: "통신사를 선택해주세요",
                text: $store.carrier
            )
            .padding(.top, store.isCarrierSelected ? 24 : 32)
            .transition(.move(edge: .top).combined(with: .opacity))
            .disabled(true)
            .overlay(alignment: .trailing) {
                Button { store.send(.carrierFieldTapped) } label: { Color.clear }
            }
        }
        
        EnterPhoneNumberView(store: store.scope(state: \.phoneNumberInput, action: \.phoneNumberInput))
        .focused($focusedField, equals: .phoneNumber)
    }
}

// MARK: - ToastAndButton
private extension FindAccountView {
    @ViewBuilder
    var toastAndButtonSection: some View {
        VStack(spacing: 0) {
            if store.toast.isVisible {
                ActionToastView(message: store.toast.message)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.3), value: store.toast.isVisible)
            }
            
            AppButton(
                title: store.isTermsAgreed ? "확인" : "다음",
                style: store.isBottomButtonEnabled ? .primary : .disabled
            ) {
                store.send(.bottomButtonTapped)
            }
            .padding(.bottom, focusedField == nil ? 24 : 12)
            .animation(.easeInOut(duration: 0.25), value: focusedField)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Sheet Overlay
private extension FindAccountView {
    @ViewBuilder
    var sheetOverlaySection: some View {
        ZStack(alignment: .bottom) {
            if store.isCarrierSelectionSheetPresented || store.isTermsAgreementSheetPresented {
                Color.dimLight
                    .onTapGesture { store.send(.dismissCarrierSheet) }
                    .transition(.opacity)
            }

            if store.isCarrierSelectionSheetPresented {
                SelectCarrierSheetView(
                    store: store.scope(state: \.carrierSelection, action: \.carrierSelection)
                )
                .transition(.move(edge: .bottom))
            }

            if store.isTermsAgreementSheetPresented {
                AgreeTermsSheetView(
                    store: store.scope(state: \.termsAgreement, action: \.termsAgreement)
                )
                .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut(duration: 0.3),
                   value: store.isCarrierSelectionSheetPresented || store.isTermsAgreementSheetPresented)
    }
}

// MARK: - Preview
#Preview {
    FindAccountView(
        store: Store(initialState: FindAccountFeature.State()) {
            FindAccountFeature()
        }
    )
}
