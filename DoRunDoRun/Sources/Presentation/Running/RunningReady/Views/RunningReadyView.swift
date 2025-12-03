//
//  RunningReadyView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI
import ComposableArchitecture

/// 러닝 전 화면 (Ready)
struct RunningReadyView: View {
    @Perception.Bindable var store: StoreOf<RunningReadyFeature>
    @State private var sheetOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
                popupSection
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    store.send(.checkLocationPermissionOnAppActive)
                }
            }
        }
    }
}

// MARK: - Server Error Section
private extension RunningReadyView {
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
private extension RunningReadyView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(alignment: .trailing, spacing: 0) {
                gpsButton

                ZStack(alignment: .bottom) {
                    friendSheet
                    startButton
                    toast
                }
                .ignoresSafeArea(edges: .top)
                .navigationBarHidden(true)
            }
        }
    }
    
    /// GPS 버튼
    var gpsButton: some View {
        Button {
            store.send(.gpsButtonTapped)
        } label: {
            Image(.gps)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(store.isFollowingUserLocation ? Color.blue600 : Color.gray800)
                .frame(width: 24, height: 24)
                .padding(10)
                .background(Color.gray0)
                .clipShape(Circle())
        }
        .padding(.horizontal, 16)
        .offset(y: sheetOffset - 16) // 시트 위치 따라 이동 (위로 16)
    }
    
    /// 친구 러닝 현황 시트 섹션
    var friendSheet: some View {
        FriendRunningStatusSheetView(
            statuses: store.statuses,
            focusedFriendID: store.focusedFriendID,
            sheetOffset: $sheetOffset,
            currentOffset: $currentOffset,
            friendListButtonTapped: {
                store.send(.friendListButtonTapped)
            },
            friendTapped: { id in
                store.send(.friendTapped(id))
            },
            cheerButtonTapped: { id, name in
                store.send(.cheerButtonTapped(id, name))
            },
            loadNextPageIfNeeded: { status in
                store.send(.loadNextPageIfNeeded(currentItem: status))
            },
            isLoading: store.isLoading
        )
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .zIndex(1)
    }
    
    /// “러닝 시작하기” 버튼 섹션
    var startButton: some View {
        VStack(spacing: 0) {
            Color.gray0
                .frame(height: 76)
                .overlay(
                    AppButton(title: "러닝 시작하기") {
                        store.send(.startButtonTapped)
                    }
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 20)
                )
        }
        .background(Color.gray0.ignoresSafeArea(edges: .bottom))
        .zIndex(2)
    }
    
    /// 각종 Toast
    @ViewBuilder
    var toast: some View {
        if store.toast.isVisible {
            ActionToastView(message: store.toast.message)
                .padding(.bottom, 88)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.3), value: store.toast.isVisible)
                .zIndex(3)
        }
    }
}

// MARK: - Network Error Popup Section
private extension RunningReadyView {
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
private extension RunningReadyView {
    /// Action Popup Section
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
                    style: .actionAndCancel,
                    onAction: {
                        store.send(.popupActionTapped)
                    },
                    onCancel: {
                        store.send(.popup(.hide))
                    }
                )
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(11)
        }
    }
}

// MARK: - Preview
#Preview {
    RunningReadyView(
        store: Store(initialState: RunningReadyFeature.State()) {
            RunningReadyFeature()
        }
    )
}

