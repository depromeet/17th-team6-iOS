//
//  SelfieFeedDetailRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

final class SelfieFeedDetailRepositoryMock: SelfieFeedDetailRepository {
    var dummy: SelfieFeedDetailResult = .init(
        feedId: 1,
        userId: 123,
        date: "2025-09-20",
        userName: "테스트유저",
        profileImageUrl: "https://example.com/profile.jpg",
        isMyFeed: true,
        selfieTime: "2025-09-20T23:58:00Z",
        totalDistance: 5100,
        totalRunTime: 2647,
        averagePace: 360,
        cadence: 144,
        imageUrl: "https://example.com/images/selfie123.jpg",
        reactions: [
            Reaction(
                emojiType: .fire,
                totalCount: 5,
                isReactedByMe: true,
                users: [
                    ReactionUser(
                        userId: 1,
                        nickname: "러너123",
                        profileImageUrl: "https://cdn.example.com/profiles/user123.jpg",
                        isMe: true,
                        reactedAt: "2025-10-16T14:30:00Z"
                    )
                ]
            )
        ]
    )

    func fetch(feedId: Int) async throws -> SelfieFeedDetailResult {
        dummy
    }
}
