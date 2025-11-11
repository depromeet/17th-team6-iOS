//
//  SelfieFeedReactionRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

final class SelfieFeedReactionRepositoryImpl: SelfieFeedReactionRepository {
    private let service: SelfieFeedService

    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }

    func sendReaction(feedId: Int, emojiType: String) async throws -> SelfieFeedReactionResult {
        let dto = try await service.sendReaction(feedId: feedId, emojiType: emojiType)
        return dto.data.toDomain()
    }
}
