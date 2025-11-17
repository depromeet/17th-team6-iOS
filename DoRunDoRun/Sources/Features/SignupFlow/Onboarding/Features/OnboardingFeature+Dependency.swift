//
//  OnboardingFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/17/25.
//

import ComposableArchitecture

extension DependencyValues {
    /// 위치 권한 요청 UseCase
    var locationPermissionUseCase: LocationPermissionUseCaseProtocol {
        get { self[LocationPermissionUseCaseKey.self] }
        set { self[LocationPermissionUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys

private enum LocationPermissionUseCaseKey: DependencyKey {
    static let liveValue: LocationPermissionUseCaseProtocol = LocationPermissionUseCase(
        repository: LocationPermissionRepositoryImpl()
    )
    static let testValue: LocationPermissionUseCaseProtocol = LocationPermissionUseCase(
        repository: LocationPermissionRepositoryImpl()
    )
}
