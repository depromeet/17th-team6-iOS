//
//  SelfieFeedReactionRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

final class SelfieFeedReactionRepositoryMock: SelfieFeedReactionRepository {
    func sendReaction(feedId: Int, emojiType: String) async throws -> SelfieFeedReaction {
        print("[Mock] 리액션 \(emojiType) 전송 성공 (feedId: \(feedId))")
        return SelfieFeedReaction(
            selfieId: feedId,
            emojiType: EmojiType(rawValue: emojiType) ?? .surprise,
            action: .added,
            totalReactionCount: Int.random(in: 1...10)
        )
    }
}
