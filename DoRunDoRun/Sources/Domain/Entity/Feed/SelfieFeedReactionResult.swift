//
//  SelfieFeedReactionResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

struct SelfieFeedReactionResult: Equatable {
    let selfieId: Int
    let emojiType: EmojiType
    let action: ReactionAction
    let totalReactionCount: Int
}

enum ReactionAction: String, Decodable {
    case added = "ADDED"
    case removed = "REMOVED"
}

