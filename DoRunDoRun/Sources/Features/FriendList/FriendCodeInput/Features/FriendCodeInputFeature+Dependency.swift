//
//  FriendCodeInputFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import ComposableArchitecture

extension DependencyValues {
    var friendCodeUseCase: FriendCodeUseCase {
        get { self[FriendRequestUseCaseKey.self] }
        set { self[FriendRequestUseCaseKey.self] = newValue }
    }
}

private enum FriendRequestUseCaseKey: DependencyKey {
    static let liveValue: FriendCodeUseCase = FriendCodeUseCase(
        repository: FriendCodeRepositoryMock()
    )
    static let testValue: FriendCodeUseCase = FriendCodeUseCase(
        repository: FriendCodeRepositoryMock()
    )
}
