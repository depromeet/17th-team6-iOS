//
//  NotificationUnreadCountRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/15/25.
//

final class NotificationUnreadCountRepositoryMock: NotificationUnreadCountRepository {

    var unreadCount: Int = 0
    var shouldThrowError = false

    func fetchUnreadCount() async throws -> NotificationUnreadCountResult {
        if shouldThrowError {
            throw APIError.unknown
        }
        return NotificationUnreadCountResult(count: unreadCount)
    }
}
