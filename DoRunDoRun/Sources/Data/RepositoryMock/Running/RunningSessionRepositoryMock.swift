//
//  RunningSessionRepositoryMock.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

/// 서버 API Mock 구현체 (Preview 및 테스트용)
final class RunningSessionRepositoryMock: RunningSessionRepository {

    func createSession() async throws -> Int {
        // Mock 세션 ID 반환
        return 123
    }

    func saveSegments(
        sessionId: Int,
        points: [RunningPoint],
        metrics: RunningMetrics,
        isStopped: Bool
    ) async throws -> (segmentId: Int, savedCount: Int) {
        // Mock 응답 반환
        return (segmentId: 456, savedCount: points.count)
    }

    func completeSession(
        sessionId: Int,
        detail: RunningDetail,
        mapImage: Data?
    ) async throws {
        // Mock 응답 반환 (서버에 데이터 전송 시뮬레이션)
    }

    func fetchSessions(
        isSelfied: Bool?,
        startDateTime: Date?,
        endDateTime: Date?
    ) async throws -> [RunningSessionSummary] {
        // Mock 세션 목록 반환
        return [
            RunningSessionSummary.mock,
            RunningSessionSummary(
                sessionId: 2,
                createdAt: Date().addingTimeInterval(-86400),
                finishedAt: Date().addingTimeInterval(-84600),
                totalDistanceMeters: 3000,
                totalDurationSeconds: 1200,
                avgPaceSecPerKm: 400,
                avgCadenceSpm: 165,
                isSelfied: true,
                mapImageURL: URL(string: "https://example.com/map2.jpg")
            )
        ]
    }

    func fetchSessionDetail(sessionId: Int) async throws -> RunningDetail {
        // Mock 상세 정보 반환
        return RunningDetail.mock
    }
}
