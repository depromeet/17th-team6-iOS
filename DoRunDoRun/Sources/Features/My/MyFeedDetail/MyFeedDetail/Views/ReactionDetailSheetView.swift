//
//  ReactionDetailSheetView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import SwiftUI
import ComposableArchitecture

struct ReactionDetailSheetView: View {
    /// 리액션 상세 시트 상태를 관리하는 TCA 스토어
    @Perception.Bindable var store: StoreOf<ReactionDetailSheetFeature>
    /// 시트 드래그 제스처 상태 (닫기 제스처)
    @GestureState private var dragOffset: CGFloat = 0
    /// 시트 전체 높이
    var height: CGFloat = 516

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // MARK: 시트 핸들러 (상단 캡슐)
                Capsule()
                    .frame(width: 32, height: 5)
                    .foregroundStyle(Color.gray100)
                    .padding(.vertical, 16)

                // MARK: 헤더 / 탭 / 유저 리스트
                headerSection
                reactionTabs
                userList
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
                            state = min(self.height, value.translation.height)
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
            .onAppear { store.send(.onAppear) }
        }
    }
}

// MARK: - Subviews
private extension ReactionDetailSheetView {
    
    /// 상단 헤더 영역 (전체 리액션 수 표시)
    var headerSection: some View {
        HStack(spacing: 4) {
            TypographyText(text: "반응", style: .t1_700, color: .gray900)
            TypographyText(text: "\(store.totalReactionCount)", style: .t1_700, color: .gray500)
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    /// 리액션(이모지) 탭 목록
    /// - 선택 시 해당 이모지의 유저 목록을 표시합니다.
    var reactionTabs: some View {
        HStack(spacing: 8) {
            ForEach(store.reactions, id: \.emojiType) { reaction in
                WithPerceptionTracking {
                    reactionTab(for: reaction)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }

    /// 개별 리액션 탭 (이모지 + 카운트)
    func reactionTab(for reaction: ReactionViewState) -> some View {
        let isSelected = store.selectedEmoji == reaction.emojiType
        let isReactedByMe = reaction.isReactedByMe

        // 선택 및 본인 여부에 따른 색상 설정
        let backgroundColor: Color = isSelected ? .blue600 : .gray50
        let textColor: Color = isSelected ? .gray0 : (isReactedByMe ? .blue600 : .gray700)
        let borderColor: Color = isReactedByMe && !isSelected ? .blue600 : .clear

        return HStack(spacing: 4) {
            reaction.emojiType.image
                .resizable()
                .frame(width: 20, height: 20)

            TypographyText(text: "\(reaction.totalCount)", style: .b2_500, color: textColor)
        }
        .frame(width: 52, height: 32)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(.capsule)
        .onTapGesture {
            store.send(.reactionTapped(reaction.emojiType))
        }
    }

    /// 현재 선택된 리액션의 유저 목록
    var userList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(store.selectedUsers, id: \.id) { user in
                    userRow(for: user)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    /// 유저 한 명의 리액션 정보 행
    func userRow(for user: ReactionUserViewState) -> some View {
        HStack(spacing: 12) {
            ProfileImageView(
                image: Image(.profilePlaceholder),
                imageURL: user.profileImageUrl,
                style: .plain,
                size: .large
            )

            HStack(spacing: 4) {
                TypographyText(
                    text: user.nickname, style: .t2_700, color: .gray900)

                // 본인 표시 뱃지
                if user.isMe {
                    Circle()
                        .fill(Color.blue600)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("나")
                                .typography(.c1_700, color: .gray0)
                        )
                }
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.userTapped(user.id))
        }
    }
}
