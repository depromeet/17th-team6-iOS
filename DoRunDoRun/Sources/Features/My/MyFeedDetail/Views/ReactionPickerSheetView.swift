//
//  ReactionPickerSheetView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import SwiftUI
import ComposableArchitecture

struct ReactionPickerSheetView: View {
    /// 리액션 선택 시트 상태를 관리하는 TCA 스토어
    @Perception.Bindable var store: StoreOf<ReactionPickerSheetFeature>
    /// 드래그 제스처 오프셋 (닫기 시 사용)
    @GestureState private var dragOffset: CGFloat = 0
    /// 시트 높이
    var height: CGFloat = 163

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                // MARK: 상단 핸들러 (드래그 캡슐)
                Capsule()
                    .frame(width: 32, height: 5)
                    .foregroundStyle(Color.gray100)
                    .padding(.vertical, 16)

                // MARK: 리액션 이모지 버튼 목록
                HStack(spacing: 16) {
                    ForEach(store.reactions, id: \.self) { emoji in
                        Button {
                            store.send(.reactionSelected(emoji))
                        } label: {
                            emoji.image
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 60)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray0)
            .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
            .frame(height: height)
            .offset(y: max(dragOffset, 0))
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height >= 0 {
                            state = min(height, value.translation.height)
                        }
                    }
                    .onEnded { value in
                        if value.translation.height >= height / 3 {
                            store.send(.dismissRequested)
                        }
                    }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
