//
//  ReactionDetailSheetFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ReactionDetailSheetFeature {
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        /// 시트 표시 여부
        var isPresented: Bool = false
        /// 전체 리액션 목록
        var reactions: [ReactionViewState] = []
        /// 초기 표시될 이모지 (롱탭 시 선택된 것)
        var initialEmoji: EmojiType? = nil
        /// 현재 선택된 이모지
        var selectedEmoji: EmojiType? = nil
        /// 현재 선택된 이모지에 대한 유저 목록
        var selectedUsers: [ReactionUserViewState] {
            guard let selectedEmoji else { return [] }
            return reactions.first(where: { $0.emojiType == selectedEmoji })?.users ?? []
        }
        /// 전체 리액션의 총합 개수
        var totalReactionCount: Int {
            reactions.map { $0.totalCount }.reduce(0, +)
        }
    }

    // MARK: - Action
    enum Action: Equatable {
        /// 시트가 등장할 때 호출 (초기 세팅)
        case onAppear
        /// 특정 이모지 탭 (선택된 이모지 변경)
        case reactionTapped(EmojiType)
        /// 시트 닫기 요청
        case dismissRequested
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            // MARK: - onAppear: 초기 선택 설정
            case .onAppear:
                // 초기 이모지가 지정되어 있으면 해당 이모지를 선택,
                // 없으면 첫 번째 리액션으로 기본 설정
                if let initial = state.initialEmoji {
                    state.selectedEmoji = initial
                } else {
                    state.selectedEmoji = state.reactions.first?.emojiType
                }

                // 선택된 이모지의 유저 정렬 수행
                if let selected = state.selectedEmoji {
                    sortUsers(in: &state, for: selected)
                }
                return .none

            // MARK: - 특정 리액션(이모지) 탭 시
            case let .reactionTapped(emoji):
                // 선택 변경 및 유저 정렬
                state.selectedEmoji = emoji
                sortUsers(in: &state, for: emoji)
                return .none

            default:
                return .none
            }
        }
    }
}

// MARK: - Private Helpers
private extension ReactionDetailSheetFeature {
    /// 특정 이모지에 해당하는 유저 목록을 정렬합니다.
    func sortUsers(in state: inout State, for emoji: EmojiType) {
        guard let index = state.reactions.firstIndex(where: { $0.emojiType == emoji }) else { return }

        var updated = state.reactions[index]
        updated.users.sort { lhs, rhs in
            // 내가 누른 항목이 우선
            if lhs.isMe && !rhs.isMe { return true }
            if !lhs.isMe && rhs.isMe { return false }
            // 그 외는 최근순
            return lhs.reactedAtText > rhs.reactedAtText
        }
        state.reactions[index] = updated
    }
}
