//
//  SelfieFeedDetailItemMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation

struct SelfieFeedDetailItemMapper {
    static func map(from detail: SelfieFeedDetailResult) -> SelfieFeedItem {
        let dateFormatter = DateFormatterManager.shared
        let runningFormatter = RunningFormatterManager.shared
        
        let date = dateFormatter.isoDate(from: detail.selfieTime) ?? Date()
        
        // 리액션 변환
        let reactions = detail.reactions.map { reaction in
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
            isMyFeed: detail.isMyFeed,
            feedID: detail.feedId,
            dayText: dateFormatter.formatDayLabel(from: date),
            imageURL: detail.imageUrl,
            isMap: detail.imageUrl.lowercased().contains("map"),
            userName: detail.userName,
            profileImageURL: detail.profileImageUrl,
            totalDistanceText: runningFormatter.formatDistance(from: detail.totalDistance),
            totalRunTimeText: runningFormatter.formatDuration(from: Int(detail.totalRunTime)),
            averagePaceText: runningFormatter.formatPace(from: detail.averagePace),
            cadence: detail.cadence,
            reactions: reactions,
            dateText: dateFormatter.formatDateText(from: date),
            timeText: dateFormatter.formatTime(from: date),
            relativeTimeText: dateFormatter.formatRelativeTime(from: detail.selfieTime),
            selfieDate: date
        )
    }
}
