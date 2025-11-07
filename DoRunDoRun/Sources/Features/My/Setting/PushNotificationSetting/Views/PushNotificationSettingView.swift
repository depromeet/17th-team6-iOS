//
//  PushNotificationSettingView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import SwiftUI
import ComposableArchitecture

struct PushNotificationSettingView: View {
    @Perception.Bindable var store: StoreOf<PushNotificationSettingFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        marketingPushSection
                        globalPushSection
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(Color.gray100)
                            .padding(.vertical, 16)
                        detailPushSection
                        Spacer()
                    }
                    .padding(.top, 16)
                    toastSection
                }
                popupSection
            }
            .onAppear { store.send(.onAppear) }
            .navigationTitle("푸시 알림 설정")
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

// MARK: - Section: 마케팅 푸시
private extension PushNotificationSettingView {
    var marketingPushSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                TypographyText(text: "마케팅 푸시", style: .b1_500)
                if let date = store.marketingAgreementDate {
                    TypographyText(
                        text: "마케팅 정보 수신 동의 \(date)",
                        style: .c1_500,
                        color: .gray300
                    )
                } else {
                    TypographyText(
                        text: "마케팅 정보 수신 해제",
                        style: .c1_500,
                        color: .gray300
                    )
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { store.isMarketingPushOn },
                set: { store.send(.toggleMarketingPush($0)) }
            ))
            .labelsHidden()
            .tint(.blue600)
        }
        .frame(height: 60)
        .padding(.leading, 28)
        .padding(.trailing, 20)
    }
}

// MARK: - Section: 전체 알림
private extension PushNotificationSettingView {
    var globalPushSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                TypographyText(text: "알림 받기", style: .b1_500)
                TypographyText(
                    text: "다양한 알림을 실시간으로 받아요.",
                    style: .c1_500,
                    color: .gray300
                )
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { store.isGlobalPushOn },
                set: { store.send(.toggleGlobalPush($0)) }
            ))
            .labelsHidden()
            .tint(.blue600)
        }
        .frame(height: 60)
        .padding(.leading, 28)
        .padding(.trailing, 20)
    }
}

// MARK: - Section: 세부 알림
private extension PushNotificationSettingView {
    var detailPushSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(store.detailToggles.enumerated()), id: \.element.id) { index, item in
                WithPerceptionTracking {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            TypographyText(text: item.title, style: .b1_500)
                            TypographyText(text: item.description, style: .c1_500, color: .gray300)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { item.isOn },
                            set: { store.send(.toggleDetailItem(index, $0)) }
                        ))
                        .labelsHidden()
                        .tint(.blue600)
                        .disabled(!store.isGlobalPushOn)
                    }
                    .frame(height: 60)
                    .padding(.leading, 28)
                    .padding(.trailing, 20)
                    .opacity(store.isGlobalPushOn ? 1.0 : 0.3)
                }
            }
        }
    }
}

// MARK: - Toast
private extension PushNotificationSettingView {
    @ViewBuilder
    var toastSection: some View {
        if store.toast.isVisible {
            ActionToastView(message: store.toast.message)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
}

// MARK: - Popup
private extension PushNotificationSettingView {
    @ViewBuilder
    var popupSection: some View {
        if store.popup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.send(.popupCancelTapped)
                    }

                ActionPopupView(
                    title: store.popup.title,
                    message: store.popup.message,
                    actionTitle: store.popup.actionTitle,
                    cancelTitle: store.popup.cancelTitle,
                    style: .destructive,
                    onAction: {
                        store.send(.popupConfirmTapped)
                    },
                    onCancel: {
                        store.send(.popupCancelTapped)
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
        PushNotificationSettingView(
            store: Store(
                initialState: PushNotificationSettingFeature.State()
            ) {
                PushNotificationSettingFeature()
            }
        )
    }
}
