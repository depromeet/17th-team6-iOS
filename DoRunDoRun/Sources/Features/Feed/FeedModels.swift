//
//  FeedModels.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/31/25.
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

///------------------------------------------------------------

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

///------------------------------------------------------------------------

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

// MARK: Friends


// MARK: - Welcome5
struct CerificatedFriendsContainerEntity: Decodable {
    let status, message, timestamp: String
    let data: FriendEmptyContainer
}

// MARK: - DataClass
struct FriendEmptyContainer: Decodable {
    let users: [CertificatedFriendEntity]
}

// MARK: - User
struct CertificatedFriendEntity: Decodable {
    let userId: Int
    let userName: String
    let userImageUrl: String
    let postingTime: Date
    let isMe: Bool
}

