//
//  RunningSessionCompleter.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

/// 러닝 세션 완료 전담 UseCase
/// 지도 이미지가 준비된 후 서버에 최종 데이터 전송
protocol RunningSessionCompleterProtocol {
    /// 러닝 세션 완료 처리
    /// - Parameters:
    ///   - sessionId: 세션 ID
    ///   - detail: 러닝 상세 정보
    ///   - mapImage: 지도 이미지 데이터
    func complete(
        sessionId: Int,
        detail: RunningDetail,
        mapImage: Data?
    ) async throws
}

final class RunningSessionCompleter: RunningSessionCompleterProtocol {
    private let sessionRepository: RunningSessionRepository

    init(sessionRepository: RunningSessionRepository) {
        self.sessionRepository = sessionRepository
    }

    func complete(
        sessionId: Int,
        detail: RunningDetail,
        mapImage: Data?
    ) async throws {
        try await sessionRepository.completeSession(
            sessionId: sessionId,
            detail: detail,
            mapImage: mapImage
        )
    }
}
