//
//  NotificationService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

protocol NotificationService {
    func getNotifications(page: Int, size: Int) async throws -> NotificationsResponseDTO
    func patchNotificationRead(notificationId: Int) async throws
}

final class NotificationServiceImpl: NotificationService {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func getNotifications(page: Int, size: Int) async throws -> NotificationsResponseDTO {
        try await apiClient.request(
            NotificationAPI.notifications(page: page, size: size),
            responseType: NotificationsResponseDTO.self
        )
    }
    
    func patchNotificationRead(notificationId: Int) async throws {
        struct EmptyResponse: Decodable {} // 서버에서 data: {} 반환
        _ = try await apiClient.request(
            NotificationAPI.notificationRead(notificationId: notificationId),
            responseType: EmptyResponse.self
        )
    }
}
