//
//  NotificationUnreadCountUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/15/25.
//

protocol NotificationUnreadCountUseCaseProtocol {
    func execute() async throws -> NotificationUnreadCountResult
}

final class NotificationUnreadCountUseCase: NotificationUnreadCountUseCaseProtocol {
    
    private let repository: NotificationUnreadCountRepository
    
    init(repository: NotificationUnreadCountRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> NotificationUnreadCountResult {
        try await repository.fetchUnreadCount()
    }
}
