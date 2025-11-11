//
//  FeedEntity.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//


import Foundation

struct FeedListContainerEntity: Decodable {
    let data: FeedListDataEntity
}

// MARK: - DataClass
struct FeedListDataEntity: Decodable {
    let userSummary: UserSummaryEntity
    let feeds: FeedListFeedsEntity
}

// MARK: - Content
struct FeedListFeedsEntity: Decodable {
    let contents: [FeedEntity]
    let meta: FeedListMeta
}

// MARK: - Feed
struct FeedEntity: Decodable {
    let feedId: Int
    let date, userName: String
    let profileImageUrl: String
    let isMyFeed: Bool
    let selfieTime: String
    let totalDistance, totalRunTime, averagePace, cadence: Int
    let imageUrl: String
    let reactions: [FeedReactionEntity]
}

// MARK: - Reaction
struct FeedReactionEntity: Decodable {
    let emojiType: String
    let totalCount: Int
    let users: [FeedReactionUserEntity]
}

// MARK: - User
struct FeedReactionUserEntity: Decodable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String
    let isMe: Bool
    let reactedAt: String
}

// MARK: - UserSummary
struct UserSummaryEntity: Decodable {
    let name: String
    let profileImageUrl: String
    let friendCount, totalDistance, selfieCount: Int
}

// MARK: - Meta
struct FeedListMeta: Decodable {
    let page, size, totalElements, totalPages: Int
    let first, last, hasNext, hasPrevious: Bool
}
