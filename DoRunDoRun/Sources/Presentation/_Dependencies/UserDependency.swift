//
//  UserDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

extension DependencyValues {
    // MARK: - 유저 현재 위치 조회
    var userLocationUseCase: UserLocationUseCaseProtocol {
        get { self[UserLocationUseCaseKey.self] }
        set { self[UserLocationUseCaseKey.self] = newValue }
    }
    
    // MARK: - 유저 프로필 조회
    var userProfileUseCase: UserProfileUseCaseProtocol {
        get { self[UserProfileUseCaseKey.self] }
        set { self[UserProfileUseCaseKey.self] = newValue }
    }
    
    // MARK: - 유저 프로필 수정
    var userProfileUpdateUseCase: UserProfileUpdateUseCaseProtocol {
        get { self[UserProfileUpdateUseCaseKey.self] }
        set { self[UserProfileUpdateUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

/// 유저 현재 위치 조회
private enum UserLocationUseCaseKey: DependencyKey {
    static let liveValue: UserLocationUseCaseProtocol = {
        return UserLocationUseCase(repository: UserLocationRepositoryImpl())
    }()

    static let testValue: UserLocationUseCaseProtocol = UserLocationUseCase(
        repository: UserLocationRepositoryMock()
    )
}

/// 유저 프로필 조회
private enum UserProfileUseCaseKey: DependencyKey {
    static let liveValue: UserProfileUseCaseProtocol = UserProfileUseCase(
        repository: UserProfileRepositoryImpl()
    )
    
    static let testValue: UserProfileUseCaseProtocol = UserProfileUseCase(
        repository: UserProfileRepositoryMock()
    )
}

/// 유저 프로필 수정
private enum UserProfileUpdateUseCaseKey: DependencyKey {
    static let liveValue: UserProfileUpdateUseCaseProtocol = UserProfileUpdateUseCase(
        repository: UserProfileUpdateRepositoryImpl()
    )
    static let testValue: UserProfileUpdateUseCaseProtocol = UserProfileUpdateUseCase(
        repository: UserProfileUpdateRepositoryMock()
    )
}
