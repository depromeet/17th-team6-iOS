//
//  FeedViewModel.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//


struct FeedViewModel {
    let feedID: Int
    let timeAgo: String
    let userName: String
    let profileImageURL: String
    let isMyFeed: Bool
    let selfieTime: String?
    let totalDistance, totalRunTime, averagePace, cadence: String
    let imageURL: String
    var reactions: [FeedReaction]
}

enum Emoji: String, Hashable {
    case SURPRISE, HEART, THUMBS_UP, CONGRATS, FIRE

    var imageName: String {
        switch self {
            case .CONGRATS: return "emoji_congrats"
            case .FIRE: return "emoji_fire"
            case .HEART: return "emoji_heart"
            case .SURPRISE: return "emoji_surprise"
            case .THUMBS_UP: return "emoji_thumbs_up"
        }
    }
}
