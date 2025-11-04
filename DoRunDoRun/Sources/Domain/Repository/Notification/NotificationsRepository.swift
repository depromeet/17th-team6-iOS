//
//  NotificationsRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

protocol NotificationsRepository {
    func fetchNotifications(page: Int, size: Int) async throws -> [NotificationsResult]
}
