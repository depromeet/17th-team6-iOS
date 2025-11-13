//
//  MySessionDetailFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import ComposableArchitecture

extension DependencyValues {
    var runSessionDetailUseCase: RunningSessionDetailFetcherProtocol {
        get { self[RunningSessionDetailFetcherKey.self] }
        set { self[RunningSessionDetailFetcherKey.self] = newValue }
    }
    
    var selfieUploadableUseCase: SelfieUploadableUseCaseProtocol {
        get { self[SelfieUploadableUseCaseKey.self] }
        set { self[SelfieUploadableUseCaseKey.self] = newValue }
    }
}

private enum RunningSessionDetailFetcherKey: DependencyKey {
    static let liveValue: RunningSessionDetailFetcherProtocol =
        RunningSessionDetailFetcher(sessionRepository: RunningSessionRepositoryImpl())
    
    static let testValue: RunningSessionDetailFetcherProtocol =
        RunningSessionDetailFetcher(sessionRepository: RunningSessionRepositoryMock())
}


private enum SelfieUploadableUseCaseKey: DependencyKey {
    static let liveValue: SelfieUploadableUseCaseProtocol =
        SelfieUploadableUseCase(repository: SelfieUploadableRepositoryImpl())

    static let testValue: SelfieUploadableUseCaseProtocol =
        SelfieUploadableUseCase(repository: SelfieUploadableRepositoryMock())
}
