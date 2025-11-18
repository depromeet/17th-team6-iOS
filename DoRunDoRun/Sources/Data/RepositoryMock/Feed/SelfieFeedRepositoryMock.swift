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
        
        // 페이지 종료 처리
        // 3페이지 이후로는 더 이상 데이터가 없다고 가정
        guard actualPage <= 3 else {
            print("[Mock] 더 이상 페이지 없음, 빈 배열 반환")
            return SelfieFeedResult(
                userSummary: mockSummary,
                feeds: []
            )
        }
        
        // 더미 피드 생성
        let startId = (actualPage - 1) * size + 1
        let now = Date()
        
        let feeds = (0..<size).map { index -> SelfieFeed in
            let feedID = startId + index
            let userID = startId + index + 100
            let date = Calendar.current.date(byAdding: .day, value: -(feedID - 1), to: now) ?? now
            let dateString = ISO8601DateFormatter().string(from: date)
            
            // 리액션 샘플 데이터
            let reactions: [Reaction] = [
                .init(
                    emojiType: .heart,
                    totalCount: 3,
                    isReactedByMe: false,
                    users: [
                        ReactionUser(
                            userId: 1,
                            nickname: "초코송이",
                            profileImageUrl: "",
                            isMe: false,
                            reactedAt: ISO8601DateFormatter().string(from: now.addingTimeInterval(-300)) // 5분 전
                        ),
                        ReactionUser(
                            userId: 2,
                            nickname: "비락식혜",
                            profileImageUrl: "",
                            isMe: false,
                            reactedAt: ISO8601DateFormatter().string(from: now.addingTimeInterval(-120)) // 2분 전
                        )
                    ]
                ),
                .init(
                    emojiType: .fire,
                    totalCount: 2,
                    isReactedByMe: false,
                    users: [
                        ReactionUser(
                            userId: 3,
                            nickname: "꼬깔콘",
                            profileImageUrl: "",
                            isMe: false,
                            reactedAt: ISO8601DateFormatter().string(from: now.addingTimeInterval(-60)) // 1분 전
                        )
                    ]
                )
            ]
            
            // 피드 데이터 구성
            return SelfieFeed(
                feedID: feedID,
                userID: userID,
                date: String(dateString.prefix(10)),
                userName: "두런두런",
                profileImageUrl: "https://picsum.photos/id/\(100 + feedID)/100",
                isMyFeed: true,
                selfieTime: dateString,
                totalDistance: Double(5000 + (feedID * 10)),  // km
                totalRunTime: Double(2400 + (feedID * 5)),    // sec
                averagePace: Double(360 + (feedID % 5) * 3),  // sec/km
                cadence: 140 + (feedID % 3),                  // spm
                imageUrl: "https://picsum.photos/id/\(200 + feedID)/200",
                reactions: reactions
            )
        }
        
        // 네트워크 응답 딜레이를 흉내냄 (0.2초)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Mock 결과 반환
        return SelfieFeedResult(userSummary: mockSummary, feeds: feeds)
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

// MARK: - Mock User Nicknames
private let mockNicknames = [
    "비락식혜", "초코송이", "콘초", "와사비맛땅콩", "버터꿀맥주",
    "마이구미", "새우깡", "꼬깔콘", "포카칩", "죠리퐁",
    "나쵸", "허니버터칩", "칙촉", "오예스", "빈츠"
]
