//
//  SelfieFeedService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

protocol SelfieFeedService {
    func fetchFeeds(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResponseDTO
}

final class SelfieFeedServiceImpl: SelfieFeedService {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchFeeds(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResponseDTO {
        try await apiClient.request(
            FeedAPI.getFeedsByDate(currentDate: currentDate, userId: userId, page: page, size: size),
            responseType: SelfieFeedResponseDTO.self
        )
    }
}
