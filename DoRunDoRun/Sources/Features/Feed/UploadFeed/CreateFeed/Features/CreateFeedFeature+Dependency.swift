//
//  CreateFeedFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import ComposableArchitecture

extension DependencyValues {
    // MARK: - 인증 피드 생성
    var selfieFeedCreateUseCase: SelfieFeedCreateUseCaseProtocol {
        get { self[SelfieFeedCreateUseCaseKey.self] }
        set { self[SelfieFeedCreateUseCaseKey.self] = newValue }
    }
}

// MARK: - Key
private enum SelfieFeedCreateUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedCreateUseCaseProtocol =
        SelfieFeedCreateUseCase(repository: SelfieFeedCreateRepositoryImpl())
    
    static let testValue: SelfieFeedCreateUseCaseProtocol =
        SelfieFeedCreateUseCase(repository: SelfieFeedCreateRepositoryMock())
}
