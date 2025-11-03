//
//  NotificationReadRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

protocol NotificationReadRepository {
    func patchNotificationRead(notificationId: Int) async throws
}
