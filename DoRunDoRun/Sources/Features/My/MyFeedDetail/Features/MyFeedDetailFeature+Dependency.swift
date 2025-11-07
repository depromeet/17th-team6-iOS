//
//  MyFeedDetailFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import ComposableArchitecture

extension DependencyValues {
    // MARK: - 인증 피드 리액션 처리
    var selfieFeedReactionUseCase: SelfieFeedReactionUseCaseProtocol {
        get { self[SelfieFeedReactionUseCaseKey.self] }
        set { self[SelfieFeedReactionUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys
private enum SelfieFeedReactionUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedReactionUseCaseProtocol =
        SelfieFeedReactionUseCase(repository: SelfieFeedReactionRepositoryImpl())
    
    static let testValue: SelfieFeedReactionUseCaseProtocol =
        SelfieFeedReactionUseCase(repository: SelfieFeedReactionRepositoryMock())
}
