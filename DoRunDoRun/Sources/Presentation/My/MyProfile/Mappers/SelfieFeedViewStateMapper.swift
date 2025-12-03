//
//  SelfieFeedViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

import Dependencies

struct SelfieFeedViewStateMapper {
    static func map(from feeds: [SelfieFeed]) -> [SelfieFeedViewState] {
        let formatter = DateFormatterManager.shared
        
        // MARK: 그룹핑
        let grouped = Dictionary(grouping: feeds) { feed -> YearMonthKey in
            let date = formatter.isoDate(from: feed.selfieTime) ?? Date()
            return YearMonthKey(
                year: formatter.formatYear(from: date),
                month: formatter.formatMonthLabel(from: date)
            )
        }

        // MARK: 정렬
        let sortedKeys = grouped.keys.sorted {
            guard
                let d1 = formatter.date(
                    from: "\($0.year)-\($0.month.replacingOccurrences(of: "월", with: ""))",
                    format: "yyyy-M"
                ),
                let d2 = formatter.date(
                    from: "\($1.year)-\($1.month.replacingOccurrences(of: "월", with: ""))",
                    format: "yyyy-M"
                )
            else { return false }
            return d1 > d2
        }

        // MARK: 셀 구성
        var cells: [SelfieFeedViewState] = []
        for key in sortedKeys {
            cells.append(makeHeaderCell(year: key.year, month: key.month))

            if let monthFeeds = grouped[key]?.sorted(by: { $0.date > $1.date }) {
                monthFeeds.forEach { feed in
                    cells.append(makeFeedCell(from: feed, using: formatter))
                }
            }
        }

        return cells
    }
}

// MARK: - Helper Structures
private extension SelfieFeedViewStateMapper {
    struct YearMonthKey: Hashable {
        let year: String
        let month: String
    }
}

// MARK: - Cell Builders
private extension SelfieFeedViewStateMapper {
    static func makeHeaderCell(year: String, month: String) -> SelfieFeedViewState {
        let id = "header-\(year)-\(month.replacingOccurrences(of: "월", with: ""))"
        return .init(id: id, kind: .monthHeader(year: year, month: month))
    }

    static func makeFeedCell(from feed: SelfieFeed, using formatter: DateFormatterManager) -> SelfieFeedViewState {
        let date = formatter.isoDate(from: feed.selfieTime) ?? Date()
        let item = makeFeedItem(from: feed, date: date, using: formatter)
        return .init(id: "feed-\(feed.feedID)-\(feed.date)", kind: .feed(item))
    }
}

// MARK: - Feed Item Mapper
private extension SelfieFeedViewStateMapper {
    static func makeFeedItem(from feed: SelfieFeed, date: Date, using formatter: DateFormatterManager) -> SelfieFeedItem {
        let dayText = formatter.formatDayLabel(from: date)
        let dateText = formatter.formatDateText(from: date)
        let timeText = formatter.formatTime(from: date)
        let relativeTimeText = formatter.formatRelativeTime(from: feed.selfieTime)
        
        // 러닝 포맷 관련
        @Dependency(\.runningFormatter) var runningFormatter
        let distanceText = runningFormatter.formatDistance(from: feed.totalDistance)
        let durationText = runningFormatter.formatDuration(from: Int(feed.totalRunTime))
        let paceText = runningFormatter.formatPace(from: feed.averagePace)
        
        // 기타 정보
        let isMap = feed.imageUrl.lowercased().contains("map")
        let reactions = mapReactions(from: feed.reactions, using: formatter)
        
        let selfieDate = DateFormatterManager.shared.isoDate(from: feed.selfieTime) ?? Date()

        return .init(
            isMyFeed: feed.isMyFeed,
            feedID: feed.feedID,
            userID: feed.userID,
            dayText: dayText,
            imageURL: feed.imageUrl,
            isMap: isMap,
            userName: feed.userName,
            profileImageURL: feed.profileImageUrl,
            totalDistanceText: distanceText,
            totalRunTimeText: durationText,
            averagePaceText: paceText,
            cadence: feed.cadence,
            reactions: reactions,
            dateText: dateText,
            timeText: timeText,
            relativeTimeText: relativeTimeText,
            selfieDate: selfieDate
        )
    }
}

// MARK: - Reaction Mapper
private extension SelfieFeedViewStateMapper {
    static func mapReactions(from reactions: [Reaction], using formatter: DateFormatterManager) -> [ReactionViewState] {
        reactions.map { reaction in
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
    }
}
