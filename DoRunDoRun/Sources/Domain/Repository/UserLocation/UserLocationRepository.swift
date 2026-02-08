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
    /// 현재 위치 권한 상태 반환 (notDetermined 포함)
    func getAuthorizationStatus() async -> LocationAuthorizationStatus
    /// 위치 권한 요청 후 사용자 응답 대기
    func requestLocationPermission() async -> Bool
}
