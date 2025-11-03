//
//  NotificationFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import ComposableArchitecture

extension DependencyValues {
    var notificationsUseCase: NotificationsUseCaseProtocol {
        get { self[NotificationsUseCaseKey.self] }
        set { self[NotificationsUseCaseKey.self] = newValue }
    }
    
    var notificationReadUseCase: NotificationReadUseCaseProtocol {
        get { self[NotificationReadUseCaseKey.self] }
        set { self[NotificationReadUseCaseKey.self] = newValue }
    }
}

private enum NotificationsUseCaseKey: DependencyKey {
    static let liveValue: NotificationsUseCaseProtocol =
        NotificationsUseCase(repository: NotificationsRepositoryImpl())
    static let testValue: NotificationsUseCaseProtocol =
        NotificationsUseCase(repository: NotificationsRepositoryMock())
}

private enum NotificationReadUseCaseKey: DependencyKey {
    static let liveValue: NotificationReadUseCaseProtocol =
        NotificationReadUseCase(repository: NotificationReadRepositoryImpl())
    static let testValue: NotificationReadUseCaseProtocol =
        NotificationReadUseCase(repository: NotificationReadRepositoryMock())
}
