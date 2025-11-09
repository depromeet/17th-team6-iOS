//
//  ReactionPickerSheetFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ReactionPickerSheetFeature {
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        /// 시트 표시 여부
        var isPresented: Bool = false
        /// 제공되는 리액션 이모지 목록
        let reactions: [EmojiType] = [.surprise, .heart, .fire, .thumbsUp, .congrats]
        /// 사용자가 마지막으로 선택한 이모지
        var selectedEmoji: EmojiType? = nil
    }

    // MARK: - Action
    enum Action: Equatable {
        /// 사용자가 특정 리액션(이모지)을 선택함
        case reactionSelected(EmojiType)
        /// 시트 닫기 요청
        case dismissRequested
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .reactionSelected(emoji):
                state.selectedEmoji = emoji // 선택한 이모지를 저장
                return .none
                
            case .dismissRequested:
                state.selectedEmoji = nil // 닫을 때 초기화
                return .none
            }
        }
    }
}
