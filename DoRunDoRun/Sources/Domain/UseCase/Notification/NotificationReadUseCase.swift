//
//  NotificationReadUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

protocol NotificationReadUseCaseProtocol {
    func execute(notificationId: Int) async throws
}

final class NotificationReadUseCase: NotificationReadUseCaseProtocol {
    private let repository: NotificationReadRepository

    init(repository: NotificationReadRepository) {
        self.repository = repository
    }

    func execute(notificationId: Int) async throws {
        try await repository.patchNotificationRead(notificationId: notificationId)
    }
}
