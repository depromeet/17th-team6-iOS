//
//  RunningActiveViewpe.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/20/25.

import SwiftUI

import ComposableArchitecture

struct RunningActiveView: View {
    @Perception.Bindable var store: StoreOf<RunningActiveFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                
                VStack(alignment: .trailing, spacing: 16) {
                    gpsButton { store.send(.gpsButtonTapped) }
                        .padding(.horizontal, 20)
                    
                    bottomSheet(
                        distanceText: store.distanceText,
                        paceText: store.paceText,
                        durationText: store.durationText,
                        cadenceText: store.cadenceText,
                        isPaused: store.isRunningPaused,
                        onPause: { store.send(.pauseButtonTapped) },
                        onResume: { store.send(.resumeButtonTapped) },
                        onStop: { store.send(.stopButtonTapped) }
                    )
                }
            }
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
        }
    }
}

// MARK: - Subviews
extension RunningActiveView {
    private func gpsButton(onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            Image("ic_gps_m")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(10)
                .background(Color.gray0)
                .clipShape(Circle())
        }
    }
    
    private func bottomSheet(
        distanceText: String,
        paceText: String,
        durationText: String,
        cadenceText: String,
        isPaused: Bool,
        onPause: @escaping () -> Void,
        onResume: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) -> some View {
        VStack(spacing: .zero) {
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: .zero) {
                        TypographyText(text: "거리", style: .b2_500, color: .gray500)
                        TypographyText(text: distanceText, style: .h3_700, color: .blue800)
                    }
                    
                    VStack(alignment: .leading, spacing: .zero) {
                        TypographyText(text: "페이스", style: .b2_500, color: .gray500)
                        TypographyText(text: paceText, style: .t1_700, color: .gray900)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: .zero) {
                        TypographyText(text: "시간", style: .b2_500, color: .gray500)
                        TypographyText(text: durationText, style: .h3_700, color: .gray900)
                    }
                    
                    VStack(alignment: .leading, spacing: .zero) {
                        TypographyText(text: "케이던스", style: .b2_500, color: .gray500)
                        TypographyText(text: cadenceText, style: .t1_700, color: .gray900)
                    }
                }
                .frame(width: 150, alignment: .leading)
            }
            .padding(.bottom, 36)
            
            bottomButtons(
                isPaused: isPaused,
                onPause: onPause,
                onResume: onResume,
                onStop: onStop
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.gray0)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    @ViewBuilder
    private func bottomButtons(
        isPaused: Bool,
        onPause: @escaping () -> Void,
        onResume: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) -> some View {
        if isPaused {
            HStack(spacing: 12) {
                AppButton(title: "기록 종료", style: .secondary, size: .medium) {
                    onStop()
                }
                AppButton(title: "계속 달리기", style: .primary, size: .medium) {
                    onResume()
                }
            }
        } else {
            AppButton(title: "기록정지", style: .primary, size: .large) {
                onPause()
            }
        }
    }
}

#Preview {
    RunningActiveView(
        store: Store(
            initialState: RunningActiveFeature.State(),
            reducer: { RunningActiveFeature() }
        )
    )
}
