//
//  FriendRunningStatusRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

/// 유저 및 친구 러닝 상태 Repository 프로토콜의 Mock 구현체
final class FriendRunningStatusRepositoryMock: FriendRunningStatusRepository {
    func fetchRunningStatuses(page: Int, size: Int) async throws -> [FriendRunningStatus] {
        return [
            FriendRunningStatus(
                id: 1,
                nickname: "민희",
                isMe: true,
                profileImageURL: nil,
                latestRanAt: Date().addingTimeInterval(-3600), // 1시간 전
                distance: 5010,
                latitude: 37.4784,
                longitude: 126.8641
            ),
            FriendRunningStatus(
                id: 2,
                nickname: "해준",
                isMe: false,
                profileImageURL: nil,
                latestRanAt: Date().addingTimeInterval(-1800), // 30분 전
                distance: 5010,
                latitude: 37.5665,
                longitude: 126.9780
            ),
            FriendRunningStatus(
                id: 3,
                nickname: "수연",
                isMe: false,
                profileImageURL: nil,
                latestRanAt: Date().addingTimeInterval(-36000), // 10시간 전
                distance: 5010,
                latitude: 37.5700,
                longitude: 126.9820
            ),
            FriendRunningStatus(
                id: 4,
                nickname: "달리는하니",
                isMe: false,
                profileImageURL: nil,
                latestRanAt: Date().addingTimeInterval(-86400 * 3), // 3일 전
                distance: 5010,
                latitude: 37.4563,
                longitude: 126.7052
            ),
            FriendRunningStatus(
                id: 5,
                nickname: "땡땡",
                isMe: false,
                profileImageURL: nil,
                latestRanAt: Date().addingTimeInterval(-86400 * 12), // 12일 전
                distance: 5010,
                latitude: 37.4980,
                longitude: 126.7830
            )
        ]
    }
}

