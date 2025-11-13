//
//  RunningCountdownView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI
import ComposableArchitecture

/// 카운트다운 화면
/// Ready → Active 전환 직전에 나타나며 3 → 2 → 1 순서로 표시됩니다.
struct RunningCountdownView: View {
    let store: StoreOf<RunningCountdownFeature>
    @State private var progress: CGFloat = 0.0

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                backgroundLayer

                if store.isPreparing {
                    preparingContent
                } else if let count = store.count {
                    countdownContent(count)
                }
            }
            .onAppear { store.send(.onAppear) }
        }
    }
}

private extension RunningCountdownView {
    /// 반투명 배경
    var backgroundLayer: some View {
        Color.black.opacity(0.73)
            .ignoresSafeArea()
    }

    /// “잠시 후 러닝 시작”만 표시하는 준비 상태
    var preparingContent: some View {
        VStack(spacing: 8) {
            Image(.runningStart)
                .resizable()
                .frame(width: 72, height: 72)
            TypographyText(text: "잠시 후 러닝 시작", style: .h4_700, color: .gray0)
        }
        .padding(.horizontal, 30)
    }

    /// 숫자 카운트다운 표시
    func countdownContent(_ count: Int) -> some View {
        VStack(spacing: 32) {
            TypographyText(text: "잠시 후 러닝 시작", style: .h4_700, color: .gray0)

            ZStack {
                Circle()
                    .stroke(Color(hex: 0xD9D9D9).opacity(0.25), style: StrokeStyle(lineWidth: 10, lineCap: .square))
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.gray0, style: StrokeStyle(lineWidth: 10, lineCap: .square))
                    .rotationEffect(.degrees(-90))

                TypographyText(text: "\(count)", style: .countdown_700, color: .gray0)
            }
            .onAppear(perform: restartAnimation)
            .onChange(of: count) { _ in restartAnimation() }
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Animation
private extension RunningCountdownView {
    func restartAnimation() {
        progress = 0
        withAnimation(.easeInOut(duration: 1)) {
            progress = 1
        }
    }
}

// MARK: - Preview
#Preview {
    RunningCountdownView(
        store: Store(initialState: RunningCountdownFeature.State()) {
            RunningCountdownFeature()
        }
    )
}
