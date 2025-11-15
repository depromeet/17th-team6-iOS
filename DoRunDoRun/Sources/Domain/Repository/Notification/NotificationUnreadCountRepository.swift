//
//  NotificationUnreadCountRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/15/25.
//

protocol NotificationUnreadCountRepository {
    func fetchUnreadCount() async throws -> NotificationUnreadCountResult
}
