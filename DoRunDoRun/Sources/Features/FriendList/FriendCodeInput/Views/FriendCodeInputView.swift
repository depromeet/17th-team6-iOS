//
//  FriendCodeInputView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import SwiftUI
import ComposableArchitecture

struct FriendCodeInputView: View {
    @Perception.Bindable var store: StoreOf<FriendCodeInputFeature>
    @FocusState private var isFocused: Bool
    
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
            }
            .onAppear { isFocused = true }
            .navigationTitle("친구 코드 입력")
            .navigationBarTitleDisplayMode(.inline)
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
private extension FriendCodeInputView {
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TypographyText(
                text: "추가할 친구의 친구코드를\n입력해주세요.",
                style: .h2_700,
                color: .gray900,
                alignment: .left
            )
            .padding(.top, 16)
        }
    }
}

// MARK: - Input
private extension FriendCodeInputView {
    var inputSection: some View {
        InputField(
            keyboardType: .asciiCapable,
            placeholder: "친구코드 8자리 입력",
            text: $store.code
        )
        .padding(.top, 32)
        .focused($isFocused)
        .onChange(of: store.code) { store.send(.codeChanged($0)) }
    }
}

// MARK: - Toast & Button
private extension FriendCodeInputView {
    @ViewBuilder
    var toastAndButtonSection: some View {
        if store.toast.isVisible {
            ActionToastView(message: store.toast.message)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.3), value: store.toast.isVisible)
        }

        AppButton(
            title: "입력 완료",
            style: store.isButtonEnabled ? .primary : .disabled,
            size: .fullWidth
        ) {
            isFocused = false
            store.send(.submitButtonTapped)
        }
        .padding(.bottom, 24)
        .animation(.easeInOut(duration: 0.25), value: isFocused)
    }
}

// MARK: - Preview
#Preview {
    FriendCodeInputView(
        store: Store(
            initialState: FriendCodeInputFeature.State()
        ) {
            FriendCodeInputFeature()
        }
    )
}
