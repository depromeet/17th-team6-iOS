//
//  SelfieFeedCreateRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation

final class SelfieFeedCreateRepositoryImpl: SelfieFeedCreateRepository {
    private let service: SelfieFeedService

    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }

    func createFeed(data: SelfieFeedCreateRequestDTO, selfieImage: Data?) async throws {
        _ = try await service.createFeed(data: data, selfieImage: selfieImage)
    }
}
