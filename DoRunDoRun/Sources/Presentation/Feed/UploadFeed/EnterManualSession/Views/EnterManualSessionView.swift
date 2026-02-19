//
//  EnterManualSessionView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/10/26.
//

import SwiftUI
import ComposableArchitecture

struct EnterManualSessionView: View {

    @Perception.Bindable var store: StoreOf<EnterManualSessionFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
            .navigationTitle("직접 기록")
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
            .safeAreaInset(edge: .bottom) {
                AppButton(
                    title: "추가하기",
                    style: store.isRequiredFieldsFilled && !store.isLoading ? .primary : .disabled,
                    size: .fullWidth
                ) {
                    store.send(.addButtonTapped)
                }
                .disabled(!store.isRequiredFieldsFilled || store.isLoading)
                .padding(.horizontal, 20)
            }
            .navigationDestination(
                item: $store.scope(state: \.createFeed, action: \.createFeed)
            ) { store in
                CreateFeedView(store: store)
            }
        }
    }
}

// MARK: - Server Error Section
private extension EnterManualSessionView {
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
private extension EnterManualSessionView {
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 36) {

                        // MARK: - 기본 정보
                        VStack(alignment: .leading, spacing: 24) {
                            TypographyText(text: "기본 정보", style: .t2_700)

                            StartTimePickerRow(
                                title: "러닝 시작 시간",
                                required: true,
                                placeholder: "오전 00:00",
                                selectedDate: $store.startTime
                            )

                            DurationPickerRow(
                                title: "러닝 소요 시간",
                                required: true,
                                placeholder: "00:00:00",
                                selectedDuration: $store.duration
                            )

                            DistancePickerRow(
                                title: "거리",
                                required: true,
                                placeholder: "00.00",
                                whole: $store.distanceWhole,
                                decimal: $store.distanceDecimal
                            )
                        }
                        .padding(.horizontal, 20)

                        // MARK: - 구분선
                        Rectangle()
                            .frame(height: 8)
                            .foregroundStyle(Color.gray50)

                        // MARK: - 상세 정보
                        VStack(alignment: .leading, spacing: 24) {
                            TypographyText(text: "상세 정보", style: .t2_700)

                            PacePickerRow(
                                title: "페이스",
                                placeholder: "페이스 입력(선택)",
                                minute: $store.paceMinute,
                                second: $store.paceSecond
                            )

                            TextInputRow(
                                title: "케이던스",
                                placeholder: "케이던스 입력(선택)",
                                unit: store.cadence.isEmpty ? nil : "spm",
                                text: $store.cadence
                            )
                        }
                        .padding(.horizontal, 20)

                    }
                    .padding(.top, 16)
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

// MARK: - Network Error Popup Section
private extension EnterManualSessionView {
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
        EnterManualSessionView(
            store: Store(initialState: EnterManualSessionFeature.State()) {
                EnterManualSessionFeature()
            }
        )
    }
}
