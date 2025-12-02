//
//  NotificationDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

extension DependencyValues {
    // MARK: - 읽지 않은 알림 개수 조회
    var notificationUnreadCountUseCase: NotificationUnreadCountUseCaseProtocol {
        get { self[NotificationUnreadCountUseCaseKey.self] }
        set { self[NotificationUnreadCountUseCaseKey.self] = newValue }
    }
    
    // MARK: - 알림 목록 조회
    var notificationsUseCase: NotificationsUseCaseProtocol {
        get { self[NotificationsUseCaseKey.self] }
        set { self[NotificationsUseCaseKey.self] = newValue }
    }
    
    // MARK: - 알림 읽음 처리
    var notificationReadUseCase: NotificationReadUseCaseProtocol {
        get { self[NotificationReadUseCaseKey.self] }
        set { self[NotificationReadUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

/// 읽지 않은 알림 개수 조회
private enum NotificationUnreadCountUseCaseKey: DependencyKey {
    static let liveValue: NotificationUnreadCountUseCaseProtocol =
        NotificationUnreadCountUseCase(repository: NotificationUnreadCountRepositoryImpl())
    
    static let testValue: NotificationUnreadCountUseCaseProtocol =
        NotificationUnreadCountUseCase(repository: NotificationUnreadCountRepositoryMock())
}

/// 알림 목록 조회
private enum NotificationsUseCaseKey: DependencyKey {
    static let liveValue: NotificationsUseCaseProtocol =
        NotificationsUseCase(repository: NotificationsRepositoryImpl())
    static let testValue: NotificationsUseCaseProtocol =
        NotificationsUseCase(repository: NotificationsRepositoryMock())
}

/// 알림 읽음 처리
private enum NotificationReadUseCaseKey: DependencyKey {
    static let liveValue: NotificationReadUseCaseProtocol =
        NotificationReadUseCase(repository: NotificationReadRepositoryImpl())
    static let testValue: NotificationReadUseCaseProtocol =
        NotificationReadUseCase(repository: NotificationReadRepositoryMock())
}
