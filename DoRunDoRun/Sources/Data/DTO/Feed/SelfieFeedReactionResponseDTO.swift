//
//  SelfieFeedReactionResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

struct SelfieFeedReactionResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: ReactionDataDTO
}

struct ReactionDataDTO: Decodable {
    let selfieId: Int
    let emojiType: String
    let action: String
    let totalReactionCount: Int
}

extension ReactionDataDTO {
    func toDomain() -> SelfieFeedReaction {
        .init(
            selfieId: selfieId,
            emojiType: EmojiType(rawValue: emojiType) ?? .surprise,
            action: ReactionAction(rawValue: action) ?? .added,
            totalReactionCount: totalReactionCount
        )
    }
}
