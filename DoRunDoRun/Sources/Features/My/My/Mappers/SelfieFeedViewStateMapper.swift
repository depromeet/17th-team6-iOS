//
//  SelfieFeedViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

struct SelfieFeedViewStateMapper {
    static func map(from feeds: [SelfieFeed]) -> [SelfieFeedViewState] {
        let formatter = DateFormatterManager.shared
        
        // MARK: 그룹핑
        let grouped = Dictionary(grouping: feeds) { feed -> YearMonthKey in
            let date = formatter.date(from: feed.date) ?? Date()
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
        let date = formatter.date(from: feed.date) ?? Date()
        let item = makeFeedItem(from: feed, date: date, using: formatter)
        return .init(id: "feed-\(feed.id)-\(feed.date)", kind: .feed(item))
    }
}

// MARK: - Feed Item Mapper
private extension SelfieFeedViewStateMapper {
    static func makeFeedItem(from feed: SelfieFeed, date: Date, using formatter: DateFormatterManager) -> SelfieFeedItem {
        let dayText = formatter.formatDayLabel(from: date)
        let dateText = formatter.formatDateText(from: date)
        let timeText = formatter.formatTime(from: date)
        let isMap = feed.imageUrl.lowercased().contains("map")
        let durationText = formatDuration(feed.totalRunTime)
        let paceText = formatPace(feed.averagePace)
        let reactions = mapReactions(from: feed.reactions, using: formatter)
        let relativeTimeText = formatter.formatRelativeTime(from: feed.selfieTime)

        return .init(
            feedID: feed.id,
            dayText: dayText,
            imageURL: feed.imageUrl,
            isMap: isMap,
            userName: feed.userName,
            profileImageURL: feed.profileImageUrl,
            totalDistanceText: String(format: "%.2fkm", feed.totalDistance),
            totalRunTimeText: durationText,
            averagePaceText: paceText,
            cadence: feed.cadence,
            reactions: reactions,
            dateText: dateText,
            timeText: timeText,
            relativeTimeText: relativeTimeText
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

// MARK: - Formatter Helpers
private extension SelfieFeedViewStateMapper {
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
