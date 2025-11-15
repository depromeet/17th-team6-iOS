//
//  NotificationUnreadCountRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/15/25.
//

final class NotificationUnreadCountRepositoryImpl: NotificationUnreadCountRepository {
    private let service: NotificationService

    init(service: NotificationService = NotificationServiceImpl()) {
        self.service = service
    }

    func fetchUnreadCount() async throws -> NotificationUnreadCountResult {
        let dto = try await service.getUnreadCount()
        return dto.toEntity()
    }
}

