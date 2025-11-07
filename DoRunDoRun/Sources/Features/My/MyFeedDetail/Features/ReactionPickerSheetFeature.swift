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
            // 현재는 상태 변경 없이 상위 피처(MyFeedDetailFeature)로 이벤트만 전달
            default:
                return .none
            }
        }
    }
}
