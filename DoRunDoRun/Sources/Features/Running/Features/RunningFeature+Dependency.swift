//
//  RunningFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/12/25.
//

import ComposableArchitecture

extension DependencyValues {
    /// 러닝 UseCase
    var runningUseCase: RunningUseCaseProtocol {
        get { self[RunningUseCaseKey.self] }
        set { self[RunningUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

private enum RunningUseCaseKey: DependencyKey {
    static let liveValue: RunningUseCaseProtocol = RunningUseCase(
        trackingRepository: RunningTrackingRepositoryImpl(),
        sessionRepository: RunningSessionRepositoryImpl()
    )
    static let testValue: RunningUseCaseProtocol = RunningUseCase(
        trackingRepository: RunningTrackingRepositoryMock(),
        sessionRepository: RunningSessionRepositoryMock()
    )
    static let previewValue: RunningUseCaseProtocol = RunningUseCase(
        trackingRepository: RunningTrackingRepositoryMock(),
        sessionRepository: RunningSessionRepositoryMock()
    )
}
