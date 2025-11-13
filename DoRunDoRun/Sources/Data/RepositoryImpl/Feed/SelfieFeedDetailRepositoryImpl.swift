//
//  SelfieFeedDetailRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

final class SelfieFeedDetailRepositoryImpl: SelfieFeedDetailRepository {
    private let service: SelfieFeedService
    
    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }
    
    func fetch(feedId: Int) async throws -> SelfieFeedDetailResult {
        let dto = try await service.fetchFeedDetail(feedId: feedId)
        return dto.data.toDomain()
    }
}
