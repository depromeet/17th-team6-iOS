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
        repository: RunningRepositoryImpl()
    )
    static let testValue: RunningActiveUseCaseProtocol = RunningActiveUseCase(
        repository: RunningRepositoryMock()
    )
    static let previewValue: RunningActiveUseCaseProtocol = RunningActiveUseCase(
        repository: RunningRepositoryMock()
      )
}

