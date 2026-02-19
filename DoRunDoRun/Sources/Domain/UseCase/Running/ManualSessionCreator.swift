//
//  ManualSessionCreator.swift
//  DoRunDoRun
//
//  Created by Claude on 2/19/26.
//

import Foundation

protocol ManualSessionCreatorProtocol {
    func execute(request: ManualSessionRequestDTO) async throws -> RunningSessionSummary
}

final class ManualSessionCreator: ManualSessionCreatorProtocol {
    private let sessionRepository: RunningSessionRepository

    init(sessionRepository: RunningSessionRepository) {
        self.sessionRepository = sessionRepository
    }

    func execute(request: ManualSessionRequestDTO) async throws -> RunningSessionSummary {
        try await sessionRepository.createManualSession(request: request)
    }
}
