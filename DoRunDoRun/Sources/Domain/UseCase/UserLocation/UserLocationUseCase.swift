//
//  UserLocationUseCase.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/10/25.
//

protocol UserLocationUseCaseProtocol {
    /// 사용자의 현재 위치 추적 시작
    func startTracking() async throws -> AsyncThrowingStream<RunningCoordinate, Error>
    /// 위치 추적 중단
    func stopTracking() async
    /// 현재 위치 권한 상태 확인
    func hasLocationPermission() async -> Bool
    /// 현재 위치 권한 상태 반환 (notDetermined 포함)
    func getAuthorizationStatus() async -> LocationAuthorizationStatus
    /// 위치 권한 요청 후 사용자 응답 대기
    func requestLocationPermission() async -> Bool
}

final class UserLocationUseCase: UserLocationUseCaseProtocol {
    private let repository: UserLocationRepository

    init(repository: UserLocationRepository) {
        self.repository = repository
    }

    func startTracking() async throws -> AsyncThrowingStream<RunningCoordinate, Error> {
        return try await repository.startTracking()
    }

    func stopTracking() async {
        return await repository.stopTracking()
    }

    func hasLocationPermission() async -> Bool {
        return await repository.hasLocationPermission()
    }

    func getAuthorizationStatus() async -> LocationAuthorizationStatus {
        return await repository.getAuthorizationStatus()
    }

    func requestLocationPermission() async -> Bool {
        return await repository.requestLocationPermission()
    }
}
