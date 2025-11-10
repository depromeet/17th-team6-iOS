//
//  EditMyFeedDetailFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import ComposableArchitecture

extension DependencyValues {
    // MARK: - 인증 피드 수정
    var selfieFeedUpdateUseCase: SelfieFeedUpdateUseCase {
        get { self[SelfieFeedUpdateUseCaseKey.self] }
        set { self[SelfieFeedUpdateUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys
private enum SelfieFeedUpdateUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedUpdateUseCase =
        SelfieFeedUpdateUseCaseImpl(repository: SelfieFeedUpdateRepositoryImpl())
    static let testValue: SelfieFeedUpdateUseCase =
        SelfieFeedUpdateUseCaseImpl(repository: SelfieFeedUpdateRepositoryMock())
}
