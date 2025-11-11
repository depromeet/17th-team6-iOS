//
//  SelfieFeedService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

protocol SelfieFeedService {
    func fetchFeeds(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResponseDTO
    func sendReaction(feedId: Int, emojiType: String) async throws -> SelfieFeedReactionResponseDTO
    func updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResponseDTO
    func deleteFeed(feedId: Int) async throws -> SelfieFeedDeleteResponseDTO
    func fetchWeeklySelfieCount(startDate: String, endDate: String) async throws -> SelfieWeekResponseDTO
    func fetchUsersByDate(date: String) async throws -> SelfieUsersByDateResponseDTO
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
    
    func sendReaction(feedId: Int, emojiType: String) async throws -> SelfieFeedReactionResponseDTO {
        try await apiClient.request(
            FeedAPI.postReaction(feedId: feedId, emojiType: emojiType),
            responseType: SelfieFeedReactionResponseDTO.self
        )
    }
    
    func updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResponseDTO {
        try await apiClient.request(
            FeedAPI.updateFeed(feedId: feedId, data: data, selfieImage: selfieImage),
            responseType: SelfieFeedUpdateResponseDTO.self
        )
    }
    
    func deleteFeed(feedId: Int) async throws -> SelfieFeedDeleteResponseDTO {
        try await apiClient.request(
            FeedAPI.deleteFeed(feedId: feedId),
            responseType: SelfieFeedDeleteResponseDTO.self
        )
    }
    
    func fetchWeeklySelfieCount(startDate: String, endDate: String) async throws -> SelfieWeekResponseDTO {
        try await apiClient.request(
            FeedAPI.getWeeklySelfieCount(startDate: startDate, endDate: endDate),
            responseType: SelfieWeekResponseDTO.self
        )
    }
    
    func fetchUsersByDate(date: String) async throws -> SelfieUsersByDateResponseDTO {
        try await apiClient.request(
            FeedAPI.getSelfieUsersByDate(date: date),
            responseType: SelfieUsersByDateResponseDTO.self
        )
    }
}
