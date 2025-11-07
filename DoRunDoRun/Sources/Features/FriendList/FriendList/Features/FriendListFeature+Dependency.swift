//
//  FriendListFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import ComposableArchitecture

extension DependencyValues {
    /// 친구 목록 조회 UseCase
    var friendListUseCase: FriendRunningStatusUseCaseProtocol {
        get { self[FriendRunningStatusUseCaseKey.self] }
        set { self[FriendRunningStatusUseCaseKey.self] = newValue }
    }

    /// 친구 삭제 UseCase
    var friendDeleteUseCase: FriendDeleteUseCaseProtocol {
        get { self[FriendDeleteUseCaseKey.self] }
        set { self[FriendDeleteUseCaseKey.self] = newValue }
    }
    
    var myFriendCodeUseCase: MyFriendCodeUseCase {
        get { self[FriendCodeUseCaseKey.self] }
        set { self[FriendCodeUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys
private enum FriendRunningStatusUseCaseKey: DependencyKey {
    static let liveValue: FriendRunningStatusUseCaseProtocol = FriendRunningStatusUseCase(
        repository: FriendRunningStatusRepositoryImpl()
    )
    static let testValue: FriendRunningStatusUseCaseProtocol = FriendRunningStatusUseCase(
        repository: FriendRunningStatusRepositoryMock()
    )
}

private enum FriendDeleteUseCaseKey: DependencyKey {
    static let liveValue: FriendDeleteUseCaseProtocol = FriendDeleteUseCase(
        repository: FriendDeleteRepositoryImpl()
    )

    static let testValue: FriendDeleteUseCaseProtocol = FriendDeleteUseCase(
        repository: FriendDeleteRepositoryMock()
    )
}

private enum FriendCodeUseCaseKey: DependencyKey {
    static let liveValue: MyFriendCodeUseCase = MyFriendCodeUseCase(
        repository: MyFriendCodeRepositoryMock()
    )
    static let testValue: MyFriendCodeUseCase = MyFriendCodeUseCase(
        repository: MyFriendCodeRepositoryMock()
    )
}
