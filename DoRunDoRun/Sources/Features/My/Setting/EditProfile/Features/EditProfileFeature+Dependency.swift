//
//  EditProfileFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import ComposableArchitecture

extension DependencyValues {
    var userProfileUpdateUseCase: UserProfileUpdateUseCaseProtocol {
        get { self[UserProfileUpdateUseCaseKey.self] }
        set { self[UserProfileUpdateUseCaseKey.self] = newValue }
    }
}

private enum UserProfileUpdateUseCaseKey: DependencyKey {
    static let liveValue: UserProfileUpdateUseCaseProtocol = UserProfileUpdateUseCase(
        repository: UserProfileUpdateRepositoryImpl()
    )
    static let testValue: UserProfileUpdateUseCaseProtocol = UserProfileUpdateUseCase(
        repository: UserProfileUpdateRepositoryMock()
    )
}

