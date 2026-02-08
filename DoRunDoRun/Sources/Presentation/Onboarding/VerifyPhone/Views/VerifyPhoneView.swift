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
                if store.phoneNumber.filter(\.isNumber) == "00011112222" {
                    focusedField = .phoneNumber   // 인증번호로 포커스 이동 금지
                } else {
                    focusedField = store.isPhoneNumberEntered ? .verificationCode : .phoneNumber
                }
            }

            .onChange(of: store.isPhoneNumberEntered) { newValue in
                if store.phoneNumber.filter(\.isNumber) == "00011112222" {
                    focusedField = .phoneNumber
                } else {
                    focusedField = newValue ? .verificationCode : .phoneNumber
                }
            }

            .onChange(of: store.isPhoneNumberEntered) { newValue in
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

// MARK: - Title
private extension VerifyPhoneView {
    var titleSection: some View {
        TypographyText(
            text: {
                // 테스트 번호면 무조건 휴대폰 번호 입력 문구 유지
                if store.phoneNumber.filter(\.isNumber) == "00011112222" {
                    return store.mode == .signup
                        ? "환영합니다!\n휴대폰 번호로 가입해주세요."
                        : "휴대폰 번호를 입력해주세요."
                }

                // 일반 유저
                return store.isPhoneNumberEntered
                    ? "인증번호 6자리를 입력해주세요."
                    : (store.mode == .signup
                       ? "환영합니다!\n휴대폰 번호로 가입해주세요."
                       : "휴대폰 번호를 입력해주세요.")
            }(),
            style: .h2_700,
            alignment: .left
        )

        .padding(.top, 16)
        .transition(.opacity.combined(with: .slide))
        .animation(
            .easeInOut(duration: 0.3),
            value: store.isPhoneNumberEntered
                && store.phoneNumber.filter(\.isNumber) != "00011112222"
        )
    }
}

// MARK: - Input
private extension VerifyPhoneView {
    @ViewBuilder
    var inputSection: some View {
        VStack(spacing: 0) {
            // 인증번호 입력 (전송 후 표시)
            if store.isPhoneNumberEntered &&
                store.phoneNumber.filter(\.isNumber) != "00011112222" {
                InputVerificationCodeField(
                    code: $store.verificationCode,
                    timerText: store.timer.timerText,
                    isResendDisabled: store.isResendButtonDisabled,
                    onResend: { store.send(.resendTapped) }
                )
                .padding(.top, 32)
                .focused($focusedField, equals: .verificationCode)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(
                    .easeInOut(duration: 0.3),
                    value: store.isPhoneNumberEntered
                        && store.phoneNumber.filter(\.isNumber) != "00011112222"
                )
            }

            // 휴대폰 번호 입력
            InputField(
                keyboardType: .numberPad,
                label: (
                    store.isPhoneNumberEntered &&
                    store.phoneNumber.filter(\.isNumber) != "00011112222"
                ) ? "휴대폰 번호" : nil,
                placeholder: "휴대폰 번호를 입력하세요",
                text: $store.phoneNumber
            )
            .padding(
                .top,
                store.isPhoneNumberEntered
                && store.phoneNumber.filter(\.isNumber) != "00011112222"
                    ? 24
                    : 32
            )
            .focused($focusedField, equals: .phoneNumber)
            .onChange(of: store.phoneNumber) { store.send(.phoneNumberChanged($0)) }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(
                .easeInOut(duration: 0.3),
                value: store.isPhoneNumberEntered
                    && store.phoneNumber.filter(\.isNumber) != "00011112222"
            )
        }
    }
}

// MARK: - Toast & Button
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
            title:
                store.phoneNumber.filter(\.isNumber) == "00011112222"
                    ? "다음"
                    : (store.isPhoneNumberEntered ? "확인" : "인증문자 받기"),
            style: store.isBottomButtonEnabled ? .primary : .disabled
        ) {
            if store.state.isVerificationCodeEntered {
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
                        let action = store.popup.action
                        store.send(.popup(.hide))
                        if action == .findAccount {
                            store.send(.existingAccountPopupDismissed)
                        } else {
                            focusedField = .verificationCode
                        }
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
                        default:
                            break
                        }
                    },
                    onCancel: {
                        let action = store.popup.action
                        store.send(.popup(.hide))
                        if action == .findAccount {
                            store.send(.existingAccountPopupDismissed)
                        } else {
                            focusedField = .verificationCode
                        }
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
