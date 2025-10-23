//
//  FeedModles.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/24/25.
//

import Foundation
/// [Entity] -----------------
// MARK: - Welcome1
struct FeedEntity: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: FeedDataContainerEntity
}

// MARK: - DataClass
struct FeedDataContainerEntity: Decodable {
    let userSummary: UserSummaryEntity
    let feeds: [FeedDataEntity]
}

// MARK: - Feed
struct FeedDataEntity: Decodable {
    let feedID: Int
    let date, userName, selfieTime: String
    let totalDistance: Double
    let totalRunTime: Int
    let averagePace: String
    let cadence: Int
    let imageURL: String
    let reactions: [ReactionEntity]
}

// MARK: - Reaction
struct ReactionEntity: Decodable {
    let emojiType: String
    let count: Int
}

// MARK: - UserSummary
struct UserSummaryEntity: Decodable {
    let name: String
    let friendCount: String
    let totalDistance: String
    let selfieCount: Int
}


/// [Domain] -----------------------------------------------

struct FeedData {
    let name: String
    let friendCount: Int
    let totalDistnace: Int
    let selfieCount: Int
}

struct FeedDetailInfo {
    let feedID: Int
    let date: Date
    let userName: String
    let selfieTime: Date
    let totalDistance: Double
    let totalRunTime: Int
    let averagePace: String
    let cadence: Int
    let imageURL: URL?
    let reactions: [FeedReaction]
}

struct FeedReaction {
    let type: EmojiType
    let count: Int

    enum EmojiType: String {
        case fire = "FIRE"
    }
}
