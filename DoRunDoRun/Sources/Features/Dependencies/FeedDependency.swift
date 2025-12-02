//
//  FeedDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

extension DependencyValues {
    // MARK: - 주간 인증 개수 조회
    var selfieWeekUseCase: SelfieWeekUseCaseProtocol {
        get { self[SelfieWeekUseCaseKey.self] }
        set { self[SelfieWeekUseCaseKey.self] = newValue }
    }
    
    // MARK: - 특정 날짜 인증 사용자 조회
    var selfieUserUseCase: SelfieUserUseCaseProtocol {
        get { self[SelfieUserUseCaseKey.self] }
        set { self[SelfieUserUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 생성 가능 여부 조회
    var selfieUploadableUseCase: SelfieUploadableUseCaseProtocol {
        get { self[SelfieUploadableUseCaseKey.self] }
        set { self[SelfieUploadableUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 생성
    var selfieFeedCreateUseCase: SelfieFeedCreateUseCaseProtocol {
        get { self[SelfieFeedCreateUseCaseKey.self] }
        set { self[SelfieFeedCreateUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 조회
    var selfieFeedsUseCase: SelfieFeedUseCaseProtocol {
        get { self[SelfieFeedsUseCaseKey.self] }
        set { self[SelfieFeedsUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 단건 조회
    var selfieFeedDetailUseCase: SelfieFeedDetailUseCaseProtocol {
        get { self[SelfieFeedDetailUseCaseKey.self] }
        set { self[SelfieFeedDetailUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 수정
    var selfieFeedUpdateUseCase: SelfieFeedUpdateUseCaseProtocol {
        get { self[SelfieFeedUpdateUseCaseKey.self] }
        set { self[SelfieFeedUpdateUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 삭제
    var selfieFeedDeleteUseCase: SelfieFeedDeleteUseCaseProtocol {
        get { self[SelfieFeedDeleteUseCaseKey.self] }
        set { self[SelfieFeedDeleteUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증 피드 리액션
    var selfieFeedReactionUseCase: SelfieFeedReactionUseCaseProtocol {
        get { self[SelfieFeedReactionUseCaseKey.self] }
        set { self[SelfieFeedReactionUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

/// 주간 인증 개수 조회
private enum SelfieWeekUseCaseKey: DependencyKey {
    static let liveValue: SelfieWeekUseCaseProtocol =
        SelfieWeekUseCase(repository: SelfieWeekRepositoryImpl())

    static let testValue: SelfieWeekUseCaseProtocol =
        SelfieWeekUseCase(repository: SelfieWeekRepositoryMock())
}

/// 특정 날짜 인증 사용자 조회
private enum SelfieUserUseCaseKey: DependencyKey {
    static let liveValue: SelfieUserUseCaseProtocol =
        SelfieUserUseCase(repository: SelfieUserRepositoryImpl())
    
    static let testValue: SelfieUserUseCaseProtocol =
        SelfieUserUseCase(repository: SelfieUserRepositoryMock())
}

/// 인증 피드 생성 가능 여부 조회
private enum SelfieUploadableUseCaseKey: DependencyKey {
    static let liveValue: SelfieUploadableUseCaseProtocol =
        SelfieUploadableUseCase(repository: SelfieUploadableRepositoryImpl())

    static let testValue: SelfieUploadableUseCaseProtocol =
        SelfieUploadableUseCase(repository: SelfieUploadableRepositoryMock())
}

/// 인증 피드 생성
private enum SelfieFeedCreateUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedCreateUseCaseProtocol =
        SelfieFeedCreateUseCase(repository: SelfieFeedCreateRepositoryImpl())
    
    static let testValue: SelfieFeedCreateUseCaseProtocol =
        SelfieFeedCreateUseCase(repository: SelfieFeedCreateRepositoryMock())
}

/// 인증 피드 조회
private enum SelfieFeedsUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedUseCaseProtocol =
        SelfieFeedUseCase(repository: SelfieFeedRepositoryImpl())
    
    static let testValue: SelfieFeedUseCaseProtocol =
        SelfieFeedUseCase(repository: SelfieFeedRepositoryMock())
}

/// 인증 피드 단건 조회
private enum SelfieFeedDetailUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedDetailUseCaseProtocol =
        SelfieFeedDetailUseCase(repository: SelfieFeedDetailRepositoryImpl())
    static let testValue: SelfieFeedDetailUseCaseProtocol =
        SelfieFeedDetailUseCase(repository: SelfieFeedDetailRepositoryMock())
}


/// 인증 피드 수정
private enum SelfieFeedUpdateUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedUpdateUseCaseProtocol =
        SelfieFeedUpdateUseCase(repository: SelfieFeedUpdateRepositoryImpl())
    static let testValue: SelfieFeedUpdateUseCaseProtocol =
        SelfieFeedUpdateUseCase(repository: SelfieFeedUpdateRepositoryMock())
}

/// 인증 피드 삭제
private enum SelfieFeedDeleteUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedDeleteUseCaseProtocol =
        SelfieFeedDeleteUseCase(repository: SelfieFeedDeleteRepositoryImpl())
    static let testValue: SelfieFeedDeleteUseCaseProtocol =
        SelfieFeedDeleteUseCase(repository: SelfieFeedDeleteRepositoryMock())
}


/// 인증 피드 리액션
private enum SelfieFeedReactionUseCaseKey: DependencyKey {
    static let liveValue: SelfieFeedReactionUseCaseProtocol =
        SelfieFeedReactionUseCase(repository: SelfieFeedReactionRepositoryImpl())
    static let testValue: SelfieFeedReactionUseCaseProtocol =
        SelfieFeedReactionUseCase(repository: SelfieFeedReactionRepositoryMock())
}
