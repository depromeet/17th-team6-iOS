//
//  RunningReadyFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import ComposableArchitecture

extension DependencyValues {
    /// 유저 및 친구 러닝 상태 UseCase
    var friendRunningStatusUseCase: FriendRunningStatusUseCaseProtocol {
        get { self[FriendRunningStatusUseCaseKey.self] }
        set { self[FriendRunningStatusUseCaseKey.self] = newValue }
    }
    
    /// 친구 응원하기 UseCase
    var friendReactionUseCase: FriendReactionUseCaseProtocol {
        get { self[FriendReactionUseCaseKey.self] }
        set { self[FriendReactionUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

private enum FriendRunningStatusUseCaseKey: DependencyKey {
    static let liveValue: FriendRunningStatusUseCaseProtocol = FriendRunningStatusUseCase(
        repository: FriendRunningStatusRepositoryMock()
    )
    static let testValue: FriendRunningStatusUseCaseProtocol = FriendRunningStatusUseCase(
        repository: FriendRunningStatusRepositoryMock()
    )
}

private enum FriendReactionUseCaseKey: DependencyKey {
    static let liveValue: FriendReactionUseCaseProtocol = FriendReactionUseCase(
        repository: FriendReactionRepositoryMock()
    )
    static let testValue: FriendReactionUseCaseProtocol = FriendReactionUseCase(
        repository: FriendReactionRepositoryMock()
    )
}
