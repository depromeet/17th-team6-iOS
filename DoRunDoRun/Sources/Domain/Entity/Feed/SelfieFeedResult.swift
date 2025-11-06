//
//  SelfieFeedResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

struct SelfieFeedResult: Equatable {
    let userSummary: UserSummary
    let feeds: [SelfieFeed]
}

struct UserSummary: Equatable {
    let name: String
    let profileImageUrl: String?
    let friendCount: Int
    let totalDistance: Double
    let selfieCount: Int
}

struct SelfieFeed: Equatable, Identifiable {
    let id: Int
    let date: String
    let userName: String
    let profileImageUrl: String
    let isMyFeed: Bool
    let selfieTime: String
    let totalDistance: Double
    let totalRunTime: Double
    let averagePace: Double
    let cadence: Int
    let imageUrl: String
    let reactions: [Reaction]
}

struct Reaction: Equatable {
    let emojiType: String
    let totalCount: Int
    let isReactedByMe: Bool
    let users: [ReactionUser]
}

struct ReactionUser: Equatable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String
    let isMe: Bool
    let reactedAt: String
}
