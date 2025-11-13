//
//  AccountInfoView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import SwiftUI
import ComposableArchitecture

struct AccountInfoView: View {
    @Perception.Bindable var store: StoreOf<AccountInfoFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
            .onAppear { store.send(.onAppear) }
            .navigationTitle("가입 정보")
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

// MARK: - Server Error Section
private extension AccountInfoView {
    /// Server Error Section
    @ViewBuilder
    var serverErrorSection: some View {
        if let serverErrorType = store.serverError.serverErrorType {
            ServerErrorView(serverErrorType: serverErrorType) {
                store.send(.serverError(.retryButtonTapped))
            }
        }
    }
}

// MARK: - Main Section
private extension AccountInfoView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(alignment: .leading, spacing: 0) {
                if store.isLoading {
                    ProgressView("불러오는 중...")
                } else if let profile = store.profile {
                    infoRow(title: "가입 휴대폰 번호", value: profile.phoneNumber)
                    infoRow(title: "가입일자", value: profile.signUpDate)
                }
                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
        }
    }
    
    /// Info Row
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            TypographyText(text: title, style: .b1_500, color: .gray900)
            Spacer()
            TypographyText(text: value, style: .b2_500, color: .gray400)
        }
        .frame(height: 44)
    }
}

// MARK: - Network Error Popup Section
private extension AccountInfoView {
    /// Networ Error Popup Section
    @ViewBuilder
    var networkErrorPopupSection: some View {
        if store.networkErrorPopup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                NetworkErrorPopupView {
                    store.send(.networkErrorPopup(.retryButtonTapped))
                }
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(10)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AccountInfoView(
            store: Store(
                initialState: AccountInfoFeature.State()
            ) {
                AccountInfoFeature()
            }
        )
    }
}
