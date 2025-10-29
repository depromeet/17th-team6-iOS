//
//  AgreeTermsView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI

import ComposableArchitecture

struct AgreeTermsView: View {
    let store: StoreOf<AgreeTermsFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                agreementListSection
                Spacer()
                bottomButton
            }
            .padding(.horizontal, 20)
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

// MARK: - Subviews
extension AgreeTermsView {
    private var titleSection: some View {
        TypographyText(
            text: "회원가입을 위해 아래 약관에\n동의해주세요.",
            style: .h2_700,
            alignment: .left
        )
        .padding(.top, 16)
    }
    
    private var agreementListSection: some View {
        AgreeTermsListView(
            store: store.scope(state: \.agreeTermsList, action: \.agreeTermsList)
        )
        .padding(.top, 32)
    }

    private var bottomButton: some View {
        AppButton(
            title: "동의하고 계속하기",
            style: store.isEssentialAgreed ? .primary : .disabled
        ) {
            store.send(.bottomButtonTapped)
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Preview
#Preview {
    AgreeTermsView(
        store: Store(
            initialState: AgreeTermsFeature.State(type: .signUp),
            reducer: { AgreeTermsFeature() }
        )
    )
}
