//
//  SelfieFeedItemMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation

struct SelfieFeedItemMapper {
    static func map(from feed: SelfieFeed) -> SelfieFeedItem {
        let dateFormatter = DateFormatterManager.shared
        let runningFormatter = RunningFormatterManager.shared
        let date = dateFormatter.isoDate(from: feed.selfieTime) ?? Date()
        
        // 날짜 관련 포맷
        let dayText = dateFormatter.formatDayLabel(from: date)
        let dateText = dateFormatter.formatDateText(from: date)
        let timeText = dateFormatter.formatTime(from: date)
        let relativeTimeText = dateFormatter.formatRelativeTime(from: feed.selfieTime)

        // 러닝 데이터 포맷
        let totalDistanceText = runningFormatter.formatDistance(from: feed.totalDistance)
        let totalRunTimeText = runningFormatter.formatDuration(from: Int(feed.totalRunTime))
        let averagePaceText = runningFormatter.formatPace(from: feed.averagePace)

        // 리액션 리스트 변환
        let reactions = feed.reactions.map { reaction in
            let users = reaction.users.map {
                ReactionUserViewState(
                    id: $0.userId,
                    nickname: $0.nickname,
                    profileImageUrl: $0.profileImageUrl,
                    isMe: $0.isMe,
                    reactedAtText: dateFormatter.formatRelativeTime(from: $0.reactedAt)
                )
            }
            return ReactionViewState(
                emojiType: reaction.emojiType,
                totalCount: reaction.totalCount,
                isReactedByMe: reaction.isReactedByMe,
                users: users
            )
        }

        return SelfieFeedItem(
            isMyFeed: feed.isMyFeed,
            feedID: feed.id,
            dayText: dayText,
            imageURL: feed.imageUrl,
            isMap: feed.imageUrl.lowercased().contains("map"),
            userName: feed.userName,
            profileImageURL: feed.profileImageUrl,
            totalDistanceText: totalDistanceText,
            totalRunTimeText: totalRunTimeText,
            averagePaceText: averagePaceText,
            cadence: feed.cadence,
            reactions: reactions,
            dateText: dateText,
            timeText: timeText,
            relativeTimeText: relativeTimeText
        )
    }

    static func mapList(from feeds: [SelfieFeed]) -> [SelfieFeedItem] {
        feeds.map { map(from: $0) }
    }
}
