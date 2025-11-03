//
//  NotificationsRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

final class NotificationsRepositoryImpl: NotificationsRepository {
    private let service: NotificationService

    init(service: NotificationService = NotificationServiceImpl()) {
        self.service = service
    }

    func fetchNotifications(page: Int, size: Int) async throws -> [NotificationsResult] {
        let response = try await service.getNotifications(page: page, size: size)
        return response.data.content.map { $0.toEntity() }
    }
}
