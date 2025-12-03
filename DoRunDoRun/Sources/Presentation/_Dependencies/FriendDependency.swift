//
//  FriendDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

extension DependencyValues {
    // MARK: - 내 친구 코드 복사
    var myFriendCodeUseCase: MyFriendCodeUseCase {
        get { self[FriendCodeUseCaseKey.self] }
        set { self[FriendCodeUseCaseKey.self] = newValue }
    }
    
    // MARK: - 친구 코드로 친구 추가
    var friendCodeUseCase: FriendCodeUseCase {
        get { self[FriendRequestUseCaseKey.self] }
        set { self[FriendRequestUseCaseKey.self] = newValue }
    }
    
    // MARK: - 친구 삭제
    var friendDeleteUseCase: FriendDeleteUseCaseProtocol {
        get { self[FriendDeleteUseCaseKey.self] }
        set { self[FriendDeleteUseCaseKey.self] = newValue }
    }
    
    // MARK: - 친구 목록 조회
    var friendListUseCase: FriendRunningStatusUseCaseProtocol {
        get { self[FriendRunningStatusUseCaseKey.self] }
        set { self[FriendRunningStatusUseCaseKey.self] = newValue }
    }
    
    // MARK: - 친구 러닝 현황 조회
    var friendRunningStatusUseCase: FriendRunningStatusUseCaseProtocol {
        get { self[FriendRunningStatusUseCaseKey.self] }
        set { self[FriendRunningStatusUseCaseKey.self] = newValue }
    }
    
    // MARK: - 친구 응원하기
    var friendReactionUseCase: FriendReactionUseCaseProtocol {
        get { self[FriendReactionUseCaseKey.self] }
        set { self[FriendReactionUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

/// 내 친구 코드 복사
private enum FriendCodeUseCaseKey: DependencyKey {
    static let liveValue: MyFriendCodeUseCase = MyFriendCodeUseCase(
        repository: MyFriendCodeRepositoryImpl()
    )
    static let testValue: MyFriendCodeUseCase = MyFriendCodeUseCase(
        repository: MyFriendCodeRepositoryMock()
    )
}

/// 친구 삭제
private enum FriendDeleteUseCaseKey: DependencyKey {
    static let liveValue: FriendDeleteUseCaseProtocol = FriendDeleteUseCase(
        repository: FriendDeleteRepositoryImpl()
    )

    static let testValue: FriendDeleteUseCaseProtocol = FriendDeleteUseCase(
        repository: FriendDeleteRepositoryMock()
    )
}

/// 친구 코드로 친구 추가
private enum FriendRequestUseCaseKey: DependencyKey {
    static let liveValue: FriendCodeUseCase = FriendCodeUseCase(
        repository: FriendCodeRepositoryImpl()
    )
    static let testValue: FriendCodeUseCase = FriendCodeUseCase(
        repository: FriendCodeRepositoryMock()
    )
}

/// 친구 목록 조회 & 친구 러닝 현황 조회
private enum FriendRunningStatusUseCaseKey: DependencyKey {
    static let liveValue: FriendRunningStatusUseCaseProtocol = FriendRunningStatusUseCase(
        repository: FriendRunningStatusRepositoryImpl()
    )
    static let testValue: FriendRunningStatusUseCaseProtocol = FriendRunningStatusUseCase(
        repository: FriendRunningStatusRepositoryMock()
    )
}

/// 친구 응원하기
private enum FriendReactionUseCaseKey: DependencyKey {
    static let liveValue: FriendReactionUseCaseProtocol = FriendReactionUseCase(
        repository: FriendReactionRepositoryImpl()
    )
    static let testValue: FriendReactionUseCaseProtocol = FriendReactionUseCase(
        repository: FriendReactionRepositoryMock()
    )
}
