//
//  SelfieFeedItemMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation

struct SelfieFeedItemMapper {
    static func map(from feed: SelfieFeed) -> SelfieFeedItem {
        let formatter = DateFormatterManager.shared
        let date = formatter.date(from: feed.date) ?? Date()

        // 날짜 관련 포맷
        let dayText = formatter.formatDayLabel(from: date)
        let dateText = formatter.formatDateText(from: date)
        let timeText = formatter.formatTime(from: date)
        let relativeTimeText = formatter.formatRelativeTime(from: feed.selfieTime)

        // 러닝 데이터 포맷
        let totalDistanceText = String(format: "%.2fkm", feed.totalDistance)
        let totalRunTimeText = formatDuration(feed.totalRunTime)
        let averagePaceText = formatPace(feed.averagePace)

        // 리액션 리스트 변환
        let reactions = feed.reactions.map { reaction in
            let users = reaction.users.map {
                ReactionUserViewState(
                    id: $0.userId,
                    nickname: $0.nickname,
                    profileImageUrl: $0.profileImageUrl,
                    isMe: $0.isMe,
                    reactedAtText: formatter.formatRelativeTime(from: $0.reactedAt)
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

// MARK: - Formatter Helpers
private extension SelfieFeedItemMapper {
    static func formatDuration(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, secs)
            : String(format: "%02d:%02d", minutes, secs)
    }

    static func formatPace(_ seconds: Double) -> String {
        let paceSeconds = Int(seconds)
        let paceMin = paceSeconds / 60
        let paceSec = paceSeconds % 60
        return String(format: "%d'%02d\"", paceMin, paceSec)
    }
}
