//
//  SelfieFeedsUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

protocol SelfieFeedsUseCaseProtocol {
    func execute(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResult
}

final class SelfieFeedsUseCase: SelfieFeedsUseCaseProtocol {
    private let repository: SelfieFeedRepository

    init(repository: SelfieFeedRepository = SelfieFeedRepositoryImpl()) {
        self.repository = repository
    }

    func execute(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResult {
        try await repository.fetchFeeds(currentDate: currentDate, userId: userId, page: page, size: size)
    }
}
