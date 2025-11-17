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
    ///   - request: 러닝 완료 요청 데이터
    ///   - mapImage: 지도 이미지 데이터
    /// - Returns: 서버에서 반환한 지도 이미지 URL
    func complete(
        sessionId: Int,
        request: RunningCompleteRequest,
        mapImage: Data?
    ) async throws -> String?
}

final class RunningSessionCompleter: RunningSessionCompleterProtocol {
    private let sessionRepository: RunningSessionRepository

    init(sessionRepository: RunningSessionRepository) {
        self.sessionRepository = sessionRepository
    }

    func complete(
        sessionId: Int,
        request: RunningCompleteRequest,
        mapImage: Data?
    ) async throws -> String? {
        return try await sessionRepository.completeSession(
            sessionId: sessionId,
            request: request,
            mapImage: mapImage
        )
    }
}
