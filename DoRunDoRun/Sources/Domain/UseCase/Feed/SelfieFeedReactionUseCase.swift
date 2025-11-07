//
//  SelfieFeedReactionUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

protocol SelfieFeedReactionUseCaseProtocol {
    func execute(feedId: Int, emojiType: String) async throws -> SelfieFeedReaction
}

final class SelfieFeedReactionUseCase: SelfieFeedReactionUseCaseProtocol {
    private let repository: SelfieFeedReactionRepository

    init(repository: SelfieFeedReactionRepository) {
        self.repository = repository
    }

    func execute(feedId: Int, emojiType: String) async throws -> SelfieFeedReaction {
        try await repository.sendReaction(feedId: feedId, emojiType: emojiType)
    }
}

