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
        case reaction(Emoji)
        case reactionSuccess(Emoji)
    }

    @Dependency(\.getFeedRepository) var feedRepository: FeedRepositoryProtocol

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
                case let .reaction(emoji):
                    let feedID = state.feedViewModel.feedID
                    return .run { send in
                        do {
                            let worker = FeedWorker(repository: feedRepository)
                            try await worker.plusReaction(
                                feedID: feedID,
                                emojiType: emoji
                            )
                            await send(.reactionSuccess(emoji))
                        } catch {
                            print("피드 반응 오류: \(error)")
                        }
                    }
                case let .reactionSuccess(emoji):
                    if let index = state.feedViewModel.reactions.firstIndex(where: { $0.emojiType == emoji }) {
                        state.feedViewModel.reactions[index].totalCount += 1
                    }
                    return .none
            }
        }
    }
}
