//
//  NotificationsUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

protocol NotificationsUseCaseProtocol {
    func execute(page: Int, size: Int) async throws -> [NotificationsResult]
}

final class NotificationsUseCase: NotificationsUseCaseProtocol {
    private let repository: NotificationsRepository

    init(repository: NotificationsRepository) {
        self.repository = repository
    }

    func execute(page: Int, size: Int) async throws -> [NotificationsResult] {
        try await repository.fetchNotifications(page: page, size: size)
    }
}
