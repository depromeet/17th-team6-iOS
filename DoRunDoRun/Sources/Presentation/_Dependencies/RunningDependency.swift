//
//  RunningDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

extension DependencyValues {
    // MARK: - 러닝 세션 조회
    var runSessionsUseCase: RunningSessionFetcherProtocol {
        get { self[RunningSessionFetcherKey.self] }
        set { self[RunningSessionFetcherKey.self] = newValue }
    }
    
    // MARK: - 러닝 세션 단건 조회
    var runSessionDetailUseCase: RunningSessionDetailFetcherProtocol {
        get { self[RunningSessionDetailFetcherKey.self] }
        set { self[RunningSessionDetailFetcherKey.self] = newValue }
    }
    
    // MARK: - 러닝 진행
    var runningUseCase: RunningUseCaseProtocol {
        get { self[RunningUseCaseKey.self] }
        set { self[RunningUseCaseKey.self] = newValue }
    }
    
    // MARK: - 러닝 완료
    var runningSessionCompleter: RunningSessionCompleterProtocol {
        get { self[RunningSessionCompleterKey.self] }
        set { self[RunningSessionCompleterKey.self] = newValue }
    }

    // MARK: - 수기 세션 생성
    var manualSessionCreator: ManualSessionCreatorProtocol {
        get { self[ManualSessionCreatorKey.self] }
        set { self[ManualSessionCreatorKey.self] = newValue }
    }
}

// MARK: - Keys

/// 러닝 세션 조회
private enum RunningSessionFetcherKey: DependencyKey {
    static let liveValue: RunningSessionFetcherProtocol =
        RunningSessionFetcher(sessionRepository: RunningSessionRepositoryImpl())

    static let testValue: RunningSessionFetcherProtocol =
        RunningSessionFetcher(sessionRepository: RunningSessionRepositoryMock())
}

/// 러닝 세션 단건 조회
private enum RunningSessionDetailFetcherKey: DependencyKey {
    static let liveValue: RunningSessionDetailFetcherProtocol =
        RunningSessionDetailFetcher(sessionRepository: RunningSessionRepositoryImpl())
    
    static let testValue: RunningSessionDetailFetcherProtocol =
        RunningSessionDetailFetcher(sessionRepository: RunningSessionRepositoryMock())
}

/// 러닝 진행
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

/// 러닝 완료
private enum RunningSessionCompleterKey: DependencyKey {
    static let liveValue: RunningSessionCompleterProtocol = RunningSessionCompleter(
        sessionRepository: RunningSessionRepositoryImpl()
    )

    static let testValue: RunningSessionCompleterProtocol = RunningSessionCompleter(
        sessionRepository: RunningSessionRepositoryMock()
    )

    static let previewValue: RunningSessionCompleterProtocol = RunningSessionCompleter(
        sessionRepository: RunningSessionRepositoryMock()
    )
}

/// 수기 세션 생성
private enum ManualSessionCreatorKey: DependencyKey {
    static let liveValue: ManualSessionCreatorProtocol =
        ManualSessionCreator(sessionRepository: RunningSessionRepositoryImpl())

    static let testValue: ManualSessionCreatorProtocol =
        ManualSessionCreator(sessionRepository: RunningSessionRepositoryMock())
}
