//
//  SelfieFeedUpdateUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

protocol SelfieFeedUpdateUseCaseProtocol {
    func execute(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResult
}

final class SelfieFeedUpdateUseCase: SelfieFeedUpdateUseCaseProtocol {
    private let repository: SelfieFeedUpdateRepository

    init(repository: SelfieFeedUpdateRepository = SelfieFeedUpdateRepositoryImpl()) {
        self.repository = repository
    }

    func execute(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResult {
        try await repository.updateFeed(feedId: feedId, data: data, selfieImage: selfieImage)
    }
}
