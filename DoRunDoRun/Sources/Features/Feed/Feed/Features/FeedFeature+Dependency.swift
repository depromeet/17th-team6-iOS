//
//  FeedFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import ComposableArchitecture

extension DependencyValues {
    // MARK: - 주간 인증 개수 조회
    var selfieWeekUseCase: SelfieWeekUseCaseProtocol {
        get { self[SelfieWeekUseCaseKey.self] }
        set { self[SelfieWeekUseCaseKey.self] = newValue }
    }
    
    // MARK: - 특정 날짜 인증 사용자 조회
    var selfieUserUseCase: SelfieUserUseCaseProtocol {
        get { self[SelfieUserUseCaseKey.self] }
        set { self[SelfieUserUseCaseKey.self] = newValue }
    }
    
    // MARK: - 읽지 않은 알림 개수 조회
    var notificationUnreadCountUseCase: NotificationUnreadCountUseCaseProtocol {
        get { self[NotificationUnreadCountUseCaseKey.self] }
        set { self[NotificationUnreadCountUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys
private enum SelfieWeekUseCaseKey: DependencyKey {
    static let liveValue: SelfieWeekUseCaseProtocol =
        SelfieWeekUseCase(repository: SelfieWeekRepositoryImpl())

    static let testValue: SelfieWeekUseCaseProtocol =
        SelfieWeekUseCase(repository: SelfieWeekRepositoryMock())
}

private enum SelfieUserUseCaseKey: DependencyKey {
    static let liveValue: SelfieUserUseCaseProtocol =
        SelfieUserUseCase(repository: SelfieUserRepositoryImpl())
    
    static let testValue: SelfieUserUseCaseProtocol =
        SelfieUserUseCase(repository: SelfieUserRepositoryMock())
}

private enum NotificationUnreadCountUseCaseKey: DependencyKey {
    static let liveValue: NotificationUnreadCountUseCaseProtocol =
        NotificationUnreadCountUseCase(repository: NotificationUnreadCountRepositoryImpl())
    
    static let testValue: NotificationUnreadCountUseCaseProtocol =
        NotificationUnreadCountUseCase(repository: NotificationUnreadCountRepositoryMock())
}
