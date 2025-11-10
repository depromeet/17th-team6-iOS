//
//  SelfieFeedUpdateUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

protocol SelfieFeedUpdateUseCase {
    func execute(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResponseDTO
}

final class SelfieFeedUpdateUseCaseImpl: SelfieFeedUpdateUseCase {
    private let repository: SelfieFeedUpdateRepository

    init(repository: SelfieFeedUpdateRepository = SelfieFeedUpdateRepositoryImpl()) {
        self.repository = repository
    }

    func execute(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResponseDTO {
        try await repository.updateFeed(feedId: feedId, data: data, selfieImage: selfieImage)
    }
}
