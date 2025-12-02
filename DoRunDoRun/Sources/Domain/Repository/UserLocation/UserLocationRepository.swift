//
//  UserLocationRepository.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/10/25.
//

protocol UserLocationRepository {
    /// 사용자의 현재 위치 추적 시작
    func startTracking() async throws -> AsyncThrowingStream<RunningCoordinate, Error>
    /// 위치 추적 중단
    func stopTracking() async
    /// 현재 위치 권한 상태 확인
    func hasLocationPermission() async -> Bool
}
