//
//  NotificationReadRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

final class NotificationReadRepositoryImpl: NotificationReadRepository {
    private let service: NotificationService

    init(service: NotificationService = NotificationServiceImpl()) {
        self.service = service
    }

    func patchNotificationRead(notificationId: Int) async throws {
        try await service.patchNotificationRead(notificationId: notificationId)
    }
}
