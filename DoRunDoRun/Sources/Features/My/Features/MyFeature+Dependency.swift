//
//  MyFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import ComposableArchitecture

extension DependencyValues {
    // MARK: - 러닝 세션 조회
    var runSessionsUseCase: RunningSessionFetcherProtocol {
        get { self[RunningSessionFetcherKey.self] }
        set { self[RunningSessionFetcherKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 조회
    var selfieFeedsUseCase: SelfieFeedsUseCaseProtocol {
        get { self[SelfieFeedsUseCaseKey.self] }
        set { self[SelfieFeedsUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys
private enum RunningSessionFetcherKey: DependencyKey {
    static let liveValue: RunningSessionFetcherProtocol =
        RunningSessionFetcher(sessionRepository: RunningSessionRepositoryImpl())

    static let testValue: RunningSessionFetcherProtocol =
        RunningSessionFetcher(sessionRepository: RunningSessionRepositoryMock())
}

private enum SelfieFeedsUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedsUseCaseProtocol =
        SelfieFeedsUseCase(repository: SelfieFeedRepositoryMock())
    
    static let testValue: SelfieFeedsUseCaseProtocol =
        SelfieFeedsUseCase(repository: SelfieFeedRepositoryMock())
}
