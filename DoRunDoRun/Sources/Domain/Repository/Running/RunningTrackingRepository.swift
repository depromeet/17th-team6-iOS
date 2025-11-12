//
//  RunningTrackingRepository.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

/// 로컬 디바이스 센서 기반 러닝 추적 Repository
/// CoreLocation, CoreMotion을 활용한 실시간 러닝 데이터 수집
protocol RunningTrackingRepository: AnyObject {
    /// 러닝 추적 시작: 실시간 스냅샷 스트림 반환
    func startTracking() async throws -> AsyncThrowingStream<RunningSnapshot, Error>

    /// 일시 정지 (누적 유지, 센서 중단)
    func pauseTracking() async

    /// 재개 (누적 유지, 센서 재시작)
    func resumeTracking() async throws

    /// 종료 (최종 RunningDetail 반환, 누적 초기화)
    /// - Parameter sessionId: 서버 세션 ID (있는 경우)
    func stopTracking(sessionId: Int?) async -> RunningDetail
}
