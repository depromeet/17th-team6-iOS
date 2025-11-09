//
//  FeedDetailFeature.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/6/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct FeedDetailFeature {
    @ObservableState
    struct State {
        var feedViewModel: FeedViewModel
    }

    enum Action {
        case change
        case delete
        case save
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .change:
                // TODO: 수정하기 구현
                print("수정하기")
                return .none

            case .delete:
                // TODO: 삭제하기 구현
                print("삭제하기")
                return .none

            case .save:
                // TODO: 이미지 저장 구현
                print("이미지 저장")
                return .none
            }
        }
    }
}
