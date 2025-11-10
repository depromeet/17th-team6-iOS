//
//  SelfieFeedUpdateRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

final class SelfieFeedUpdateRepositoryImpl: SelfieFeedUpdateRepository {
    private let service: SelfieFeedService
    
    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }
    
    func updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResult {
        let dto = try await service.updateFeed(feedId: feedId, data: data, selfieImage: selfieImage)
        let result = dto.data?.toDomain(feedId: feedId) ?? SelfieFeedUpdateResult(feedId: feedId, updatedImageUrl: "")
        return result
    }
}
