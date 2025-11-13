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

    // MARK: - 인증 피드 삭제
    var selfieFeedDeleteUseCase: SelfieFeedDeleteUseCaseProtocol {
        get { self[SelfieFeedDeleteUseCaseKey.self] }
        set { self[SelfieFeedDeleteUseCaseKey.self] = newValue }
    }

    // MARK: - 인증 피드 단건 조회 (Detail)
    var selfieFeedDetailUseCase: SelfieFeedDetailUseCaseProtocol {
        get { self[SelfieFeedDetailUseCaseKey.self] }
        set { self[SelfieFeedDetailUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys
private enum SelfieFeedReactionUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedReactionUseCaseProtocol =
        SelfieFeedReactionUseCase(repository: SelfieFeedReactionRepositoryImpl())
    static let testValue: SelfieFeedReactionUseCaseProtocol =
        SelfieFeedReactionUseCase(repository: SelfieFeedReactionRepositoryMock())
}

private enum SelfieFeedDeleteUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedDeleteUseCaseProtocol =
        SelfieFeedDeleteUseCase(repository: SelfieFeedDeleteRepositoryImpl())
    static let testValue: SelfieFeedDeleteUseCaseProtocol =
        SelfieFeedDeleteUseCase(repository: SelfieFeedDeleteRepositoryMock())
}

private enum SelfieFeedDetailUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedDetailUseCaseProtocol =
        SelfieFeedDetailUseCase(repository: SelfieFeedDetailRepositoryImpl())
    static let testValue: SelfieFeedDetailUseCaseProtocol =
        SelfieFeedDetailUseCase(repository: SelfieFeedDetailRepositoryMock())
}
