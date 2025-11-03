//
//  NotificationsRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import Foundation

final class NotificationsRepositoryMock: NotificationsRepository {
    func fetchNotifications(page: Int, size: Int) async throws -> [NotificationsResult] {
        print("[Mock] 알림 목록 불러오기 성공")

        return [
            NotificationsResult(
                id: 1,
                title: "친구 응원",
                message: "이 회원님을 깨웠어요.",
                senderName: "수연",
                profileImageURL: "https://example.com/profile1.jpg",
                type: .cheerFriend,
                isRead: false,
                relatedId: 101,
                selfieImageURL: "https://example.com/post1.jpg",
                createdAt: Date().addingTimeInterval(-60), // 1분 전
            ),
            NotificationsResult(
                id: 2,
                title: "피드 리액션",
                message: "이 회원님의 게시물에 리액션을 남겼습니다.",
                senderName: "두런두런두런두런",
                profileImageURL: "https://example.com/profile2.jpg",
                type: .feedReaction,
                isRead: true,
                relatedId: 202,
                selfieImageURL: "https://example.com/post2.jpg",
                createdAt: Date().addingTimeInterval(-3600), // 1시간 전
            ),
            NotificationsResult(
                id: 3,
                title: "시스템 알림",
                message: "친구를 추가하고 멀리서도 함께 러닝을 즐겨요!",
                senderName: nil,
                profileImageURL: nil,
                type: .newUserFriendReminder,
                isRead: true,
                relatedId: nil,
                selfieImageURL: nil,
                createdAt: Date().addingTimeInterval(-86400 * 3), // 3일 전
            )
        ]
    }
}
