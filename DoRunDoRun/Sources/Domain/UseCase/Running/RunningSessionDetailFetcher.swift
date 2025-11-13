//
//  RunningSessionDetailFetcher.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation

/// 러닝 세션 상세 조회 UseCase
protocol RunningSessionDetailFetcherProtocol {
    func fetchSessionDetail(sessionId: Int) async throws -> RunningDetail
}

final class RunningSessionDetailFetcher: RunningSessionDetailFetcherProtocol {
    private let sessionRepository: RunningSessionRepository

    init(sessionRepository: RunningSessionRepository) {
        self.sessionRepository = sessionRepository
    }

    func fetchSessionDetail(sessionId: Int) async throws -> RunningDetail {
        try await sessionRepository.fetchSessionDetail(sessionId: sessionId)
    }
}
