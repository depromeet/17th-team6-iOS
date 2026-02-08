//
//  SettingView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import SwiftUI
import ComposableArchitecture

struct SettingView: View {
    @Perception.Bindable var store: StoreOf<SettingFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                popupSection
                networkErrorPopupSection
            }
            .onAppear { store.send(.onAppear) }
            .scrollContentBackground(.hidden)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
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
            .navigationDestination(
                item: $store.scope(state: \.editProfile, action: \.editProfile)
            ) { store in
                EditProfileView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.accountInfo, action: \.accountInfo)
            ) { store in
                AccountInfoView(store: store)
            }.navigationDestination(
                item: $store.scope(state: \.pushNotificationSetting, action: \.pushNotificationSetting)
            ) { store in
                PushNotificationSettingView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.web, action: \.web)
            ) { store in
                SettingWebView(store: store)
            }

        }
    }
}

// MARK: - Server Error Section
private extension SettingView {
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
private extension SettingView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack {
                // MARK: - 계정 섹션
                accountSection
                divider
                policySection
                divider
                etcSection
                Spacer()
            }
        }
    }
    /// 계정 섹션
    var accountSection: some View {
        VStack {
            settingsRow(title: "프로필 수정", type: .navigable) {
                store.send(.editProfileTapped)
            }
            settingsRow(title: "가입 정보", type: .navigable) {
                store.send(.accountInfoTapped)
            }
            settingsRow(title: "푸시 알림 설정", type: .navigable) {
                store.send(.pushNotificationSettingTapped)
            }
        }
    }
    /// 정책 섹션
    var policySection: some View {
        VStack {
            settingsRow(title: "개인정보처리방침", type: .navigable) { store.send(.privacyPolicyTapped) }
            settingsRow(title: "약관 및 정책", type: .navigable) { store.send(.termsTapped) }

            HStack {
                TypographyText(text: "버전 정보", style: .b1_500, color: .gray900)
                Spacer()
                TypographyText(text: store.appVersion, style: .b2_500, color: .gray500)
            }
            .frame(height: 44)
            .padding(.horizontal, 28)
        }

    }
    /// 기타 섹션
    var etcSection: some View {
        VStack {
            settingsRow(title: "로그아웃", type: .action) { store.send(.logoutTapped) }
            settingsRow(title: "탈퇴하기", type: .action) { store.send(.withdrawTapped) }
        }
    }
    /// 공통 구분선
    var divider: some View {
        Rectangle()
            .foregroundStyle(Color.gray100)
            .frame(height: 1)
            .padding(.vertical, 8)
    }
    /// Row 타입
    enum RowType { case navigable, action }
    /// 설정 Row
    func settingsRow(title: String, type: RowType, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                TypographyText(text: title, style: .b1_500, color: .gray900)
                Spacer()
                if type == .navigable {
                    Image(.arrowRight, size: .small)
                        .renderingMode(.template)
                        .foregroundStyle(Color.gray800)
                }
            }
            .frame(height: 44)
            .padding(.leading, 28)
            .padding(.trailing, 32)
        }
    }
}

// MARK: - Network Error Popup Section
private extension SettingView {
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

// MARK: - Popup Section
private extension SettingView {
    /// Popup Section
    @ViewBuilder
    var popupSection: some View {
        if store.popup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.send(.popup(.hide))
                    }

                ActionPopupView(
                    title: store.popup.title,
                    message: store.popup.message,
                    actionTitle: store.popup.actionTitle,
                    cancelTitle: store.popup.cancelTitle,
                    style: .destructive,
                    onAction: {
                        store.send(.popup(.hide))
                        store.send(.popupConfirmTapped)
                    },
                    onCancel: {
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
    NavigationStack {
        SettingView(
            store: Store(
                initialState: SettingFeature.State(),
                reducer: { SettingFeature() }
            )
        )
    }
}
