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
    let store: StoreOf<RunningReadyFeature>
    @State private var sheetOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0

    var body: some View {
        WithPerceptionTracking {
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
}

// MARK: - Subviews
private extension RunningReadyView {
    /// GPS 버튼
    var gpsButton: some View {
        Button {
            store.send(.gpsButtonTapped)
        } label: {
            Image(.gps)
                .resizable()
                .frame(width: 24, height: 24)
                .padding(10)
                .background(Color.gray0)
                .clipShape(Circle())
        }
        .padding(.horizontal, 16)
        .offset(y: sheetOffset - 16) // 시트 위치 따라 이동 (위로 16)
    }
    
    /// 친구 현황 시트 섹션
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
            }
        )
        .onAppear {
            store.send(.onAppear)
        }
        .zIndex(1)
        
    }

    /// “오늘의 러닝 시작” 버튼 섹션
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
        .zIndex(2)
    }
    
    /// Toast
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

// MARK: - Preview
#Preview {
    RunningReadyView(
        store: Store(initialState: RunningReadyFeature.State()) {
            RunningReadyFeature()
        }
    )
}

