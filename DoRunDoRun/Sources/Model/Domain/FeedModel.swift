//
//  FeedModel.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//

import Foundation

struct FeedList {
    let feeds: [Feed]
    let userSummary: UserSummary
}

struct UserSummary {
    let name: String
    let profileImageURL: String
    let friendCount, totalDistance, selfieCount: Int
}

struct Feed {
    let feedID: Int
    let date: String // 2025-09-20
    let userName: String
    let profileImageURL: String
    let isMyFeed: Bool
    let selfieTime: Date?
    let totalDistance, totalRunTime, averagePace, cadence: Int
    let imageURL: String
    let reactions: [FeedReaction]
}

struct FeedReaction {
    let emojiType: Emoji
    var totalCount: Int
    let users: [FeedReactionUser]
}

struct FeedReactionUser {
    let userID: Int
    let nickname: String
    let profileImageURL: String
    let isMe: Bool
    let reactedAt: Date
}
