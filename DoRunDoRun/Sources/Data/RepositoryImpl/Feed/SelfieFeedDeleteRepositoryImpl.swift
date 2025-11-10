//
//  SelfieFeedDeleteRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

final class SelfieFeedDeleteRepositoryImpl: SelfieFeedDeleteRepository {
    private let service: SelfieFeedService

    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }

    func deleteFeed(feedId: Int) async throws {
        _ = try await service.deleteFeed(feedId: feedId)
    }
}
