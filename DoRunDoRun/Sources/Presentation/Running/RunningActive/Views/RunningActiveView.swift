//
//  RunningActiveViewpe.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/20/25.

import SwiftUI
import ComposableArchitecture

struct RunningActiveView: View {
    @Perception.Bindable var store: StoreOf<RunningActiveFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 42) {
                    Spacer()
                    
                    // MARK: - Distance
                    RunningStatView(
                        title: "거리",
                        value: store.distanceText,
                        titleStyle: .b1_500,
                        valueStyle: .distance_700,
                        color: primaryTextColor
                    )
                    
                    // MARK: - Stats Card
                    statsCard
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .safeAreaInset(edge: .bottom) {
                    bottomButtons
                        .padding(.horizontal, 20)
                }
            }
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
        }
    }
}

// MARK: - Style
private extension RunningActiveView {
    var primaryTextColor: Color {
        store.isRunningPaused ? .gray900 : .gray0
    }
    var backgroundColor: Color {
        store.isRunningPaused ? .gray0 : .blue600
    }
    var cardBackgroundColor: Color {
        store.isRunningPaused ? .gray50 : .blue700
    }
}

// MARK: - Stats Card
private extension RunningActiveView {
    var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            RunningStatView(title: "시간", value: store.durationText, color: primaryTextColor)
            
            HStack {
                RunningStatView(title: "페이스", value: store.paceText, color: primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)

                RunningStatView(title: "케이던스", value: store.cadenceText, color: primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
        )
    }
}

// MARK: - Bottom Buttons
private extension RunningActiveView {
    @ViewBuilder
    var bottomButtons: some View {
        if store.isRunningPaused {
            HStack(spacing: 12) {
                AppButton(title: "기록 종료", style: .cancel) {
                    store.send(.stopButtonTapped)
                }
                
                AppButton(title: "계속 달리기") {
                    store.send(.resumeButtonTapped)
                }
            }
        } else {
            AppButton(title: "기록정지", style: .primaryInverse) {
                store.send(.pauseButtonTapped)
            }
        }
    }
}

// MARK: RunningStatView
private struct RunningStatView: View {
    let title: String
    let value: String
    let titleStyle: TypographyStyle
    let valueStyle: TypographyStyle
    let color: Color
    
    // 기본 스타일 (시간/페이스/케이던스용)
    init(
        title: String,
        value: String,
        color: Color
    ) {
        self.title = title
        self.value = value
        self.titleStyle = .c1_400
        self.valueStyle = .h3_700
        self.color = color
    }
    
    // 커스텀 스타일 (거리용)
    init(
        title: String,
        value: String,
        titleStyle: TypographyStyle,
        valueStyle: TypographyStyle,
        color: Color
    ) {
        self.title = title
        self.value = value
        self.titleStyle = titleStyle
        self.valueStyle = valueStyle
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TypographyText(
                text: title,
                style: titleStyle,
                color: color
            )
            
            TypographyText(
                text: value,
                style: valueStyle,
                color: color
            )
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
