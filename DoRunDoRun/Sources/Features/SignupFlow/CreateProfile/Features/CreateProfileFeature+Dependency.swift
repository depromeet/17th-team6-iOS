//
//  CreateProfileFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import ComposableArchitecture

extension DependencyValues {
    /// 회원가입 UseCase
    var authSignupUseCase: AuthSignupUseCaseProtocol {
        get { self[AuthSignupUseCaseKey.self] }
        set { self[AuthSignupUseCaseKey.self] = newValue }
    }
}

// MARK: - Key
private enum AuthSignupUseCaseKey: DependencyKey {
    static let liveValue: AuthSignupUseCaseProtocol = AuthSignupUseCase(
        repository: AuthSignupRepositoryImpl()
    )
    static let testValue: AuthSignupUseCaseProtocol = AuthSignupUseCase(
        repository: AuthSignupRepositoryMock()
    )
}
