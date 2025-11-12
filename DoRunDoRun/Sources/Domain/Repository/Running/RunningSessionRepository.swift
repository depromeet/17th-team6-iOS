//
//  RunningSessionRepository.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

/// 서버 기반 러닝 세션 관리 Repository
/// REST API를 통한 러닝 데이터 저장 및 조회
protocol RunningSessionRepository: AnyObject {
    /// 서버에 러닝 세션 생성
    /// - Returns: 생성된 세션 ID
    func createSession() async throws -> Int

    /// 주기적으로 세그먼트 데이터 저장 (5분마다 또는 정지 시)
    /// - Parameters:
    ///   - sessionId: 세션 ID
    ///   - points: 저장할 경로 포인트 배열
    ///   - metrics: 현재 러닝 메트릭
    ///   - isStopped: 정지 상태 여부
    /// - Returns: (세그먼트 ID, 저장된 개수)
    func saveSegments(
        sessionId: Int,
        points: [RunningPoint],
        metrics: RunningMetrics,
        isStopped: Bool
    ) async throws -> (segmentId: Int, savedCount: Int)

    /// 러닝 세션 완료 (최종 데이터 및 지도 이미지 전송)
    /// - Parameters:
    ///   - sessionId: 세션 ID
    ///   - detail: 최종 러닝 상세 정보
    ///   - mapImage: 지도 이미지 데이터
    /// - Returns: 서버에서 반환한 지도 이미지 URL
    func completeSession(
        sessionId: Int,
        detail: RunningDetail,
        mapImage: Data?
    ) async throws -> String?

    /// 완료된 러닝 세션 목록 조회
    /// - Parameters:
    ///   - isSelfied: 셀피 포함 여부 필터
    ///   - startDateTime: 조회 시작 일시
    /// - Returns: 러닝 세션 요약 목록
    func fetchSessions(
        isSelfied: Bool?,
        startDateTime: Date?,
        endDateTime: Date?
    ) async throws -> [RunningSessionSummary]

    /// 특정 러닝 세션 상세 조회
    /// - Parameter sessionId: 세션 ID
    /// - Returns: 러닝 상세 정보
    func fetchSessionDetail(sessionId: Int) async throws -> RunningDetail
}
