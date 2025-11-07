//
//  SelfieFeedReactionRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

protocol SelfieFeedReactionRepository: AnyObject {
    func sendReaction(feedId: Int, emojiType: String) async throws -> SelfieFeedReaction
}
