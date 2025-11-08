//
//  RunningSessionFetcher.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

/// 러닝 세션 조회 전담 UseCase
/// 완료된 세션 목록 및 상세 조회 기능 제공
protocol RunningSessionFetcherProtocol {
    /// 러닝 세션 목록 조회
    /// - Parameters:
    ///   - isSelfied: 셀피 포함 여부 필터
    ///   - startDateTime: 조회 시작 일시
    func fetchSessions(
        isSelfied: Bool?,
        startDateTime: Date?,
        endDateTime: Date?
    ) async throws -> [RunningSessionSummary]
}

final class RunningSessionFetcher: RunningSessionFetcherProtocol {
    private let sessionRepository: RunningSessionRepository

    init(sessionRepository: RunningSessionRepository) {
        self.sessionRepository = sessionRepository
    }

    func fetchSessions(
        isSelfied: Bool?,
        startDateTime: Date?,
        endDateTime: Date?
    ) async throws -> [RunningSessionSummary] {
        try await sessionRepository.fetchSessions(
            isSelfied: isSelfied,
            startDateTime: startDateTime,
            endDateTime: endDateTime
        )
    }
}
