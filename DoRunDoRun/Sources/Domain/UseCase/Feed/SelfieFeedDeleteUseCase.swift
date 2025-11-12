//
//  SelfieFeedDeleteUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

protocol SelfieFeedDeleteUseCaseProtocol {
    func execute(feedId: Int) async throws
}

final class SelfieFeedDeleteUseCase: SelfieFeedDeleteUseCaseProtocol {
    private let repository: SelfieFeedDeleteRepository

    init(repository: SelfieFeedDeleteRepository = SelfieFeedDeleteRepositoryImpl()) {
        self.repository = repository
    }

    func execute(feedId: Int) async throws {
        try await repository.deleteFeed(feedId: feedId)
    }
}
