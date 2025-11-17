//
//  LocationPermissionUseCase.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/17/25.
//

/// 위치 권한 요청 UseCase
protocol LocationPermissionUseCaseProtocol {
    /// 위치 권한 요청
    func requestPermission() async
}

final class LocationPermissionUseCase: LocationPermissionUseCaseProtocol {
    private let repository: LocationPermissionRepository

    init(repository: LocationPermissionRepository) {
        self.repository = repository
    }

    func requestPermission() async {
        _ = await repository.requestPermission()
    }
}
