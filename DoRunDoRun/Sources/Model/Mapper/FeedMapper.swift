//
//  FeedListMapper.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/31/25.
//

import SwiftUI
import Foundation

struct FeedListMapper {
    static func toDomain(from entity: FeedListContainerEntity) -> FeedList {
        return FeedList(
            feeds: entity.data.feeds.contents.map {
                FeedMapper.toDomain(from: $0)
            },
            userSummary: UserSummaryMapper.toDomain(from:entity.data.userSummary)
        )
    }

    // MARK: - Private Mappers

    private struct UserSummaryMapper {
        static func toDomain(from entity: UserSummaryEntity) -> UserSummary {
            return UserSummary(
                name: entity.name,
                profileImageURL: entity.profileImageUrl,
                friendCount: entity.friendCount,
                totalDistance: entity.totalDistance,
                selfieCount: entity.selfieCount
            )
        }
    }

    private struct FeedMapper {
        static func toDomain(from entity: FeedEntity) -> Feed {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let selfieTime = formatter.date(from: entity.selfieTime)

            return Feed(
                feedID: entity.feedId,
                date: entity.date,
                userName: entity.userName,
                profileImageURL: entity.profileImageUrl,
                isMyFeed: entity.isMyFeed,
                selfieTime: selfieTime,
                totalDistance: entity.totalDistance,
                totalRunTime: entity.totalRunTime,
                averagePace: entity.averagePace,
                cadence: entity.cadence,
                imageURL: entity.imageUrl,
                reactions: entity.reactions.map { FeedReactionMapper.toDomain(from: $0) }
            )
        }
    }

    private struct FeedReactionMapper {
        static func toDomain(from entity: FeedReactionEntity) -> FeedReaction {
            return FeedReaction(
                emojiType: Emoji(rawValue: entity.emojiType) ?? .THUMBS_UP,
                totalCount: entity.totalCount,
                users: entity.users.map { FeedReactionUserMapper.toDomain(from: $0) }
            )
        }
    }

    private struct FeedReactionUserMapper {
        static func toDomain(from entity: FeedReactionUserEntity) -> FeedReactionUser {
            return FeedReactionUser(
                userID: entity.userId,
                nickname: entity.nickname,
                profileImageURL: entity.profileImageUrl,
                isMe: entity.isMe,
                reactedAt: Date.convertStringToDate(entity.reactedAt) ?? Date()
            )
        }
    }

    static func toViewModel(from entity: Feed) -> FeedViewModel {
        return FeedViewModel(
            feedID: entity.feedID,
            timeAgo: entity.selfieTime.relativeTimeString(),
            userName: entity.userName,
            profileImageURL: entity.profileImageURL,
            isMyFeed: entity.isMyFeed,
            selfieTime: entity.selfieTime?.toFormattedString(),
            totalDistance: String(entity.totalDistance / 1000) + "km",
            totalRunTime: entity.totalRunTime.formatTime(),
            averagePace: entity.averagePace.formatPace(),
            cadence: "\(entity.cadence)spm",
            imageURL: entity.imageURL,
            reactions: entity.reactions
            )
    }
}
