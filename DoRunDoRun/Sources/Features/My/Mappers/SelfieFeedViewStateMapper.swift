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
        
        // MARK: - 그룹 키 정의 (연도 + 월)
        struct YearMonthKey: Hashable {
            let year: String
            let month: String
        }

        // MARK: - 월별 그룹화
        let grouped = Dictionary(grouping: feeds) { feed -> YearMonthKey in
            let date = formatter.date(from: feed.date) ?? Date()
            return YearMonthKey(
                year: formatter.yearString(from: date),
                month: formatter.monthString(from: date)
            )
        }

        // MARK: - 최신순 정렬 (연월 기준)
        let sortedKeys = grouped.keys.sorted {
            guard
                let d1 = formatter.date(from: "\($0.year)-\($0.month.replacingOccurrences(of: "월", with: ""))", format: "yyyy-M"),
                let d2 = formatter.date(from: "\($1.year)-\($1.month.replacingOccurrences(of: "월", with: ""))", format: "yyyy-M")
            else {
                return false
            }
            return d1 > d2
        }

        // MARK: - 셀 생성
        var cells: [SelfieFeedViewState] = []

        for key in sortedKeys {
            // 월 헤더 추가
            let headerID = "header-\(key.year)-\(key.month.replacingOccurrences(of: "월", with: ""))"
            cells.append(
                .init(
                    id: headerID,
                    kind: .monthHeader(year: key.year, month: key.month)
                )
            )

            // 해당 월의 피드 정렬 (최신순)
            if let monthFeeds = grouped[key]?.sorted(by: { $0.date > $1.date }) {
                for feed in monthFeeds {
                    let date = formatter.date(from: feed.date) ?? Date()
                    let dayText = formatter.dayString(from: date) + "일"
                    let isMap = feed.imageUrl.lowercased().contains("map")

                    let item = SelfieFeedItem(
                        feedID: feed.id,
                        dayText: dayText,
                        imageURL: feed.imageUrl,
                        isMap: isMap
                    )

                    cells.append(
                        .init(
                            id: "feed-\(feed.id)-\(feed.date)",
                            kind: .feed(item)
                        )
                    )
                }
            }
        }

        return cells
    }
}
