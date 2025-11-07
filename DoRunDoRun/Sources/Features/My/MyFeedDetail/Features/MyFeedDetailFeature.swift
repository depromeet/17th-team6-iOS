//
//  MyFeedDetailFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyFeedDetailFeature {
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        /// 현재 표시 중인 피드 아이템
        var feed: SelfieFeedItem
        /// 리액션 상세 시트 상태
        var reactionDetail = ReactionDetailSheetFeature.State()
        /// 리액션 추가(피커) 시트 상태
        var reactionPicker = ReactionPickerSheetFeature.State()
        /// 리액션 상세 시트 표시 여부
        var isReactionDetailPresented = false
        /// 리액션 추가 시트 표시 여부
        var isReactionPickerPresented = false
        /// 상단에 표시할 최대 3개의 리액션 (최근 + 많이 사용된 순)
        var displayedReactions: [ReactionViewState] {
            let formatter = ISO8601DateFormatter()
            
            let newReactions = feed.reactions.filter { $0.totalCount == 1 }
            let existingReactions = feed.reactions.filter { $0.totalCount > 1 }
            
            let sortedNew = newReactions.sorted { lhs, rhs in
                let lhsDate = lhs.users.compactMap { formatter.date(from: $0.reactedAtText) }.max() ?? .distantPast
                let rhsDate = rhs.users.compactMap { formatter.date(from: $0.reactedAtText) }.max() ?? .distantPast
                return lhsDate > rhsDate
            }
            return Array((sortedNew + existingReactions).prefix(3))
        }
        /// 표시되지 않는 나머지 리액션 개수
        var extraReactionCount: Int {
            max(0, feed.reactions.count - 3)
        }
        /// 숨겨진 리액션 목록
        var hiddenReactions: [ReactionViewState] {
            Array(feed.reactions.dropFirst(3))
        }
    }

    // MARK: - Action
    enum Action: Equatable {
        /// 리액션 상세 시트 액션
        case reactionDetail(ReactionDetailSheetFeature.Action)
        /// 리액션 추가 피커 시트 액션
        case reactionPicker(ReactionPickerSheetFeature.Action)
        /// 리액션 탭
        case reactionTapped(ReactionViewState)
        /// 리액션 롱탭 (상세 시트 표시)
        case reactionLongPressed(ReactionViewState)
        /// 리액션 추가 버튼 탭
        case addReactionTapped
        /// 시트 닫기
        case dismissSheet
        /// 상단 뒤로가기 버튼 탭
        case backButtonTapped
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        // 하위 피처 연결
        Scope(state: \.reactionDetail, action: \.reactionDetail) { ReactionDetailSheetFeature() }
        Scope(state: \.reactionPicker, action: \.reactionPicker) { ReactionPickerSheetFeature() }
        
        Reduce { state, action in
            switch action {
                
            // MARK: - 리액션 탭: 토글 처리
            case let .reactionTapped(reaction):
                state.feed.reactions = MyFeedDetailFeature.toggleReaction(
                    in: state.feed.reactions,
                    for: reaction.emojiType
                )
                return .none

            // MARK: - 리액션 롱탭: 상세 시트 표시
            case let .reactionLongPressed(reaction):
                state.isReactionDetailPresented = true
                state.reactionDetail = .init(
                    isPresented: true,
                    reactions: state.feed.reactions,
                    initialEmoji: reaction.emojiType
                )
                return .none
                
            // 상세 시트 닫기 요청
            case .reactionDetail(.dismissRequested):
                state.isReactionDetailPresented = false
                return .none
                
            // MARK: - 리액션 추가 버튼 탭
            case .addReactionTapped:
                state.isReactionPickerPresented = true
                return .none
                
            // MARK: - 피커에서 리액션 선택 시
            case let .reactionPicker(.reactionSelected(emoji)):
                state.feed.reactions = MyFeedDetailFeature.addOrToggleReaction(
                    in: state.feed.reactions,
                    emoji: emoji
                )
                state.isReactionPickerPresented = false
                return .none

            // 피커 닫기 요청
            case .reactionPicker(.dismissRequested):
                state.isReactionPickerPresented = false
                return .none
                
            // MARK: - 시트 전체 닫기
            case .dismissSheet:
                state.isReactionDetailPresented = false
                state.isReactionPickerPresented = false
                return .none

            // 뒤로가기 버튼 탭
            case .backButtonTapped:
                return .none
                
            default:
                return .none
            }
        }
    }
}

// MARK: - Private Reaction Handling Logic
private extension MyFeedDetailFeature {
    /// 리액션 탭 시 상태를 토글합니다.
    static func toggleReaction(in reactions: [ReactionViewState], for emoji: EmojiType) -> [ReactionViewState] {
        var updatedReactions = reactions.map { item -> ReactionViewState in
            var updated = item
            if item.emojiType == emoji {
                if item.isReactedByMe {
                    // 이미 내가 누른 상태 → 취소
                    updated.isReactedByMe = false
                    updated.totalCount = max(0, item.totalCount - 1)
                    updated.users.removeAll(where: { $0.isMe })
                } else {
                    // 새로 리액션 추가
                    updated.isReactedByMe = true
                    updated.totalCount += 1
                    updated.users.append(Self.makeMyReactionUser())
                }
            }
            return updated
        }
        updatedReactions.removeAll(where: { $0.totalCount == 0 })
        return updatedReactions
    }
    
    /// 피커에서 선택된 리액션을 추가하거나 토글합니다.
    static func addOrToggleReaction(in reactions: [ReactionViewState], emoji: EmojiType) -> [ReactionViewState] {
        var updatedReactions = reactions
        if let index = updatedReactions.firstIndex(where: { $0.emojiType == emoji }) {
            // 이미 존재하는 리액션 → 토글
            var updated = updatedReactions[index]
            if updated.isReactedByMe {
                updated.isReactedByMe = false
                updated.totalCount = max(0, updated.totalCount - 1)
                updated.users.removeAll(where: { $0.isMe })
            } else {
                updated.isReactedByMe = true
                updated.totalCount += 1
                updated.users.append(Self.makeMyReactionUser())
            }
            updatedReactions[index] = updated
        } else {
            // 존재하지 않는 리액션 → 새로 추가
            let newReaction = ReactionViewState(
                emojiType: emoji,
                totalCount: 1,
                isReactedByMe: true,
                users: [Self.makeMyReactionUser()]
            )
            updatedReactions.append(newReaction)
        }
        updatedReactions.removeAll(where: { $0.totalCount == 0 })
        return updatedReactions
    }
    
    // TODO: 실제 유저의 아이디와 닉네임으로 교체 필요
    /// 현재 유저의 리액션 정보를 생성합니다.
    static func makeMyReactionUser() -> ReactionUserViewState {
        ReactionUserViewState(
            id: -1, // 로컬 임시 ID
            nickname: "Test",
            profileImageUrl: "",
            isMe: true,
            reactedAtText: ISO8601DateFormatter().string(from: Date())
        )
    }
}
