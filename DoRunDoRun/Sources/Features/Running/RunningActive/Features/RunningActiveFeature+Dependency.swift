//
//  RunningActiveFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/25/25.
//

import ComposableArchitecture

extension DependencyValues {
    /// 러닝 상태 UseCase
    var runningActiveUsecase: RunningActiveUseCaseProtocol {
        get { self[RunningActiveUseCaseKey.self] }
        set { self[RunningActiveUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

private enum RunningActiveUseCaseKey: DependencyKey {
    static let liveValue: RunningActiveUseCaseProtocol = RunningActiveUseCase(
        trackingRepository: RunningTrackingRepositoryImpl(),
        sessionRepository: RunningSessionRepositoryImpl()
    )
    static let testValue: RunningActiveUseCaseProtocol = RunningActiveUseCase(
        trackingRepository: RunningTrackingRepositoryMock(),
        sessionRepository: RunningSessionRepositoryMock()
    )
    static let previewValue: RunningActiveUseCaseProtocol = RunningActiveUseCase(
        trackingRepository: RunningTrackingRepositoryMock(),
        sessionRepository: RunningSessionRepositoryMock()
    )
}

