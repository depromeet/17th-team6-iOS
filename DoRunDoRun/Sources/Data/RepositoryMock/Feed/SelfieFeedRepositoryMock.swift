//
//  SelfieFeedRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

final class SelfieFeedRepositoryMock: SelfieFeedRepository {
    func fetchFeeds(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResult {
        let actualPage = max(page, 1)
        print("[Mock] \(actualPage)페이지 셀피 피드 불러오기 성공")

        // 3페이지까지만 데이터 제공
        guard actualPage <= 3 else {
            print("[Mock] 더 이상 페이지 없음, 빈 배열 반환")
            return SelfieFeedResult(
                userSummary: mockSummary,
                feeds: []
            )
        }

        // 페이지네이션 ID 계산
        let startId = (actualPage - 1) * size + 1

        let feeds = (0..<size).map { index -> SelfieFeed in
            let id = startId + index

            // 최근 날짜부터 과거로 역순 생성
            let date = Calendar.current.date(byAdding: .day, value: -(id - 1), to: Date()) ?? Date()
            let dateString = ISO8601DateFormatter().string(from: date)

            return SelfieFeed(
                id: id,
                date: String(dateString.prefix(10)), // yyyy-MM-dd
                userName: "두런두런",
                profileImageUrl: "https://picsum.photos/id/\(100 + id)/100",
                isMyFeed: true,
                selfieTime: dateString,
                totalDistance: Double(5000 + (id * 10)),
                totalRunTime: Double(2400 + (id * 5)),
                averagePace: Double(360 + (id % 5) * 3),
                cadence: 140 + (id % 3),
                imageUrl: "https://picsum.photos/id/\(200 + id)/200",
                reactions: []
            )
        }

        try await Task.sleep(nanoseconds: 200_000_000) // 0.2초 지연
        return SelfieFeedResult(
            userSummary: mockSummary,
            feeds: feeds
        )
    }
}

// MARK: - Mock Summary
private let mockSummary = UserSummary(
    name: "두런두런",
    profileImageUrl: "https://picsum.photos/id/10/100",
    friendCount: 7,
    totalDistance: 12345,
    selfieCount: 42
)
