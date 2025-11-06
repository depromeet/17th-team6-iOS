//
//  SelfieFeedResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

struct SelfieFeedResponseDTO: Codable {
    let status: String
    let message: String
    let timestamp: String
    let data: SelfieFeedDataDTO
}

struct SelfieFeedDataDTO: Codable {
    let userSummary: UserSummaryDTO
    let feeds: SelfieFeedContainerDTO
}

struct UserSummaryDTO: Codable {
    let name: String
    let profileImageUrl: String
    let friendCount: Int
    let totalDistance: Double
    let selfieCount: Int
}

struct SelfieFeedContainerDTO: Codable {
    let contents: [SelfieFeedDTO]
    let meta: MetaDTO
}

struct SelfieFeedDTO: Codable {
    let feedId: Int
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
    let reactions: [ReactionDTO]
}

struct ReactionDTO: Codable {
    let emojiType: String
    let totalCount: Int
    let isReactedByMe: Bool
    let users: [ReactionUserDTO]
}

struct ReactionUserDTO: Codable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String
    let isMe: Bool
    let reactedAt: String
}

struct MetaDTO: Codable {
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let first: Bool
    let last: Bool
    let hasNext: Bool
    let hasPrevious: Bool
}

extension UserSummaryDTO {
    func toDomain() -> UserSummary {
        .init(
            name: name,
            profileImageUrl: profileImageUrl,
            friendCount: friendCount,
            totalDistance: totalDistance,
            selfieCount: selfieCount
        )
    }
}

extension SelfieFeedDTO {
    func toDomain() -> SelfieFeed {
        .init(
            id: feedId,
            date: date,
            userName: userName,
            profileImageUrl: profileImageUrl,
            isMyFeed: isMyFeed,
            selfieTime: selfieTime,
            totalDistance: totalDistance,
            totalRunTime: totalRunTime,
            averagePace: averagePace,
            cadence: cadence,
            imageUrl: imageUrl,
            reactions: reactions.map { $0.toDomain() }
        )
    }
}

extension ReactionDTO {
    func toDomain() -> Reaction {
        .init(
            emojiType: emojiType,
            totalCount: totalCount,
            isReactedByMe: isReactedByMe,
            users: users.map { $0.toDomain() }
        )
    }
}

extension ReactionUserDTO {
    func toDomain() -> ReactionUser {
        .init(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            isMe: isMe,
            reactedAt: reactedAt
        )
    }
}
