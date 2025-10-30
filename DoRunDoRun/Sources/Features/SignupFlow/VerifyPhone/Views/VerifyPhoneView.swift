//
//  VerifyPhoneView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI

import ComposableArchitecture

enum Field: Equatable { case phoneNumber, verificationCode, nickname }

struct VerifyPhoneView: View {
    @Perception.Bindable var store: StoreOf<VerifyPhoneFeature>
    @FocusState private var focusedField: Field?
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    titleSection
                    inputSection
                    Spacer()
                    toastAndButtonSection
                }
                .padding(.horizontal, 20)
                popupSection
            }
            .task {
                focusedField = store.enterPhoneNumber.isPhoneNumberEntered ? .verificationCode : .phoneNumber
            }
            .onChange(of: store.enterPhoneNumber.isPhoneNumberEntered) { newValue in
                focusedField = newValue ? .verificationCode : .phoneNumber
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

// MARK: Title
private extension VerifyPhoneView {
    var titleSection: some View {
        TypographyText(
            text: store.enterPhoneNumber.isPhoneNumberEntered
                ? "인증번호 6자리를 입력해주세요."
                : (store.mode == .signup
                    ? "환영합니다!\n휴대폰 번호로 가입해주세요."
                    : "휴대폰 번호를 입력해주세요."),
            style: .h2_700,
            alignment: .left
        )
        .padding(.top, 16)
        .transition(.opacity.combined(with: .slide))
    }
}

// MARK: Input
private extension VerifyPhoneView {
    @ViewBuilder
    var inputSection: some View {
        if store.enterPhoneNumber.isPhoneNumberEntered {
            EnterVerificationCodeView(
                store: store.scope(state: \.enterVerificationCode, action: \.enterVerificationCode)
            )
            .focused($focusedField, equals: .verificationCode)
        }
        
        EnterPhoneNumberView(
            store: store.scope(state: \.enterPhoneNumber, action: \.enterPhoneNumber)
        )
        .focused($focusedField, equals: .phoneNumber)
        
    }
}

// MARK: - ToastAndButton
private extension VerifyPhoneView {
    @ViewBuilder
    var toastAndButtonSection: some View {
        if store.toast.isVisible {
            ActionToastView(message: store.toast.message)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.3), value: store.toast.isVisible)
        }
        
        if store.mode == .login {
            AppButton(
                title: "휴대폰 번호가 변경되었나요? 계정찾기",
                style: .text,
                underlineTarget: "계정찾기"
            ) {
                focusedField = nil
                store.send(.findAccountButtonTapped)
            }
            .padding(.bottom, 12)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        
        AppButton(
            title: store.enterPhoneNumber.isPhoneNumberEntered ? "확인" : "인증문자 받기",
            style: store.enterPhoneNumber.isPhoneNumberEntered
                ? (store.enterVerificationCode.isBottomButtonEnabled ? .primary : .disabled)
                : (store.enterPhoneNumber.isBottomButtonEnabled ? .primary : .disabled)
        ) {
            if store.state.enterVerificationCode.isVerificationCodeEntered {
                focusedField = nil
            }
            store.send(.bottomButtonTapped)
        }
        .padding(.bottom, focusedField == nil ? 24 : 12)
        .animation(.easeInOut(duration: 0.25), value: focusedField)

    }
}

// MARK: - Popup
private extension VerifyPhoneView {
    @ViewBuilder
    var popupSection: some View {
        if store.popup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = .verificationCode
                        store.send(.popup(.hide))
                    }

                ActionPopupView(
                    title: store.popup.title,
                    message: store.popup.message,
                    actionTitle: store.popup.actionTitle,
                    cancelTitle: store.popup.cancelTitle,
                    style: .actionAndCancel,
                    onAction: {
                        switch store.popup.action {
                        case .signup:
                            store.send(.popup(.hide))
                            store.send(.signupButtonTapped)
                        case .findAccount:
                            store.send(.popup(.hide))
                            store.send(.findAccountButtonTapped)
                        case .none:
                            break
                        }
                    },
                    onCancel: {
                        focusedField = .verificationCode
                        store.send(.popup(.hide))
                    }
                )
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
}

// MARK: - Preview
#Preview {
    VerifyPhoneView(
        store: Store(
            initialState: VerifyPhoneFeature.State(mode: .login)
        ) {
            VerifyPhoneFeature()
        }
    )
}
