//
//  AccountInfo+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import ComposableArchitecture

extension DependencyValues {
    var userProfileUseCase: UserProfileUseCaseProtocol {
        get { self[UserProfileUseCaseKey.self] }
        set { self[UserProfileUseCaseKey.self] = newValue }
    }
}

private enum UserProfileUseCaseKey: DependencyKey {
    static let liveValue: UserProfileUseCaseProtocol = UserProfileUseCase(
        repository: UserProfileRepositoryImpl()
    )
    
    static let testValue: UserProfileUseCaseProtocol = UserProfileUseCase(
        repository: UserProfileRepositoryMock()
    )
}
