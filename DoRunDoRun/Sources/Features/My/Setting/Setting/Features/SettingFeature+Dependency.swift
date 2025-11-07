//
//  SettingFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import ComposableArchitecture

extension DependencyValues {
    var authLogoutUseCase: AuthLogoutUseCaseProtocol {
        get { self[AuthLogoutUseCaseKey.self] }
        set { self[AuthLogoutUseCaseKey.self] = newValue }
    }

    var authWithdrawUseCase: AuthWithdrawUseCaseProtocol {
        get { self[AuthWithdrawUseCaseKey.self] }
        set { self[AuthWithdrawUseCaseKey.self] = newValue }
    }
}

private enum AuthLogoutUseCaseKey: DependencyKey {
    static let liveValue: AuthLogoutUseCaseProtocol = AuthLogoutUseCase(
        repository: AuthLogoutRepositoryImpl()
    )
    static let testValue: AuthLogoutUseCaseProtocol = AuthLogoutUseCase(
        repository: AuthLogoutRepositoryMock()
    )
}

private enum AuthWithdrawUseCaseKey: DependencyKey {
    static let liveValue: AuthWithdrawUseCaseProtocol = AuthWithdrawUseCase(
        repository: AuthWithdrawRepositoryImpl()
    )
    static let testValue: AuthWithdrawUseCaseProtocol = AuthWithdrawUseCase(
        repository: AuthWithdrawRepositoryMock()
    )
}
