//
//  SelfieUploadableUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation

protocol SelfieUploadableUseCaseProtocol {
    func execute(runSessionId: Int) async throws -> SelfieUploadableResult
}

final class SelfieUploadableUseCase: SelfieUploadableUseCaseProtocol {
    private let repository: SelfieUploadableRepository

    init(repository: SelfieUploadableRepository = SelfieUploadableRepositoryImpl()) {
        self.repository = repository
    }

    func execute(runSessionId: Int) async throws -> SelfieUploadableResult {
        try await repository.checkUploadable(runSessionId: runSessionId)
    }
}
