//
//  NotificationsRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import Foundation

final class NotificationsRepositoryMock: NotificationsRepository {
    func fetchNotifications(page: Int, size: Int) async throws -> [NotificationsResult] {
        let actualPage = max(page, 1)
        print("[Mock] \(actualPage)페이지 알림 불러오기 성공")

        guard actualPage <= 3 else { // 3페이지까지만 데이터 제공
            return []
        }

        return (1...size).map { index in
            NotificationsResult(
                id: (actualPage - 1) * size + index,
                title: "페이지 \(actualPage) - 알림 \(index)",
                message: "이건 Mock 데이터입니다.",
                senderName: "두런이",
                profileImageURL: nil,
                type: .feedReaction,
                isRead: false,
                relatedId: nil,
                selfieImageURL: nil,
                createdAt: Date().addingTimeInterval(Double(-index * 600))
            )
        }
    }
}
