//
//  ReactionBarView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI
import ComposableArchitecture

struct ReactionBarView: View {
    /// 표시할 리액션 목록 (최대 3종류)
    let displayedReactions: [ReactionViewState]
    /// 숨겨진 리액션 목록 (3개 초과분)
    let hiddenReactions: [ReactionViewState]
    /// 숨겨진 리액션 개수 (ex. +2)
    let extraReactionCount: Int

    /// 리액션 탭 이벤트
    var onTapReaction: ((ReactionViewState) -> Void)? = nil
    /// 리액션 롱탭 이벤트 (리액션 상세 시트 표시 등)
    var onLongPressReaction: ((ReactionViewState) -> Void)? = nil
    /// 리액션 추가 버튼 탭 이벤트
    var onTapAddReaction: (() -> Void)? = nil

    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 8) {
                // MARK: 표시 중인 리액션 버튼들
                ForEach(displayedReactions, id: \.emojiType) { reaction in
                    reactionButton(for: reaction)
                }
                // MARK: 추가 리액션("+N") 버튼
                if extraReactionCount > 0 {
                    extraReactionButton
                }
                // MARK: 리액션 추가 버튼
                addReactionButton
                Spacer()
            }
        }
    }
}

// MARK: - Subviews
private extension ReactionBarView {
    /// 개별 리액션 버튼
    func reactionButton(for reaction: ReactionViewState) -> some View {
        let isReactedByMe = reaction.isReactedByMe

        return HStack(spacing: 2) {
            reaction.emojiType.image
                .resizable()
                .frame(width: 20, height: 20)

            TypographyText(
                text: "\(reaction.totalCount)",
                style: .b2_500,
                color: isReactedByMe ? .blue600 : .gray700
            )
        }
        .frame(width: 52, height: 32)
        .background(Color.gray50)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isReactedByMe ? Color.blue600 : Color.clear, lineWidth: 1)
        )
        .clipShape(.capsule)
        .contentShape(Rectangle()) // 터치 영역 확장
        .onTapGesture {
            onTapReaction?(reaction)
        }
        .onLongPressGesture(minimumDuration: 0.4) {
            onLongPressReaction?(reaction)
        }
    }

    /// "+N" 추가 리액션 버튼
    var extraReactionButton: some View {
        HStack(spacing: 2) {
            TypographyText(
                text: "+\(extraReactionCount)",
                style: .b2_500,
                color: .gray700
            )
        }
        .frame(width: 52, height: 32)
        .background(Color.gray50)
        .clipShape(.capsule)
        .contentShape(Rectangle())
        .onTapGesture {
            // 첫 번째 숨겨진 리액션을 기준으로 롱탭 동작 트리거
            if let firstHidden = hiddenReactions.first {
                onLongPressReaction?(firstHidden)
            }
        }
    }

    /// 리액션 추가 버튼
    var addReactionButton: some View {
        HStack {
            Button {
                onTapAddReaction?()
            } label: {
                Image(.emoji, size: .small)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray50)
                    .clipShape(.capsule)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - EmojiType → Image 매핑
extension EmojiType {
    /// 각 이모지 타입에 해당하는 이미지 반환
    var image: Image {
        switch self {
        case .surprise: return Image(.emojiSurprised)
        case .heart: return Image(.emojiHeart)
        case .thumbsUp: return Image(.emojiThumbsup)
        case .congrats: return Image(.emojiCongrats)
        case .fire: return Image(.emojiFire)
        }
    }
}
