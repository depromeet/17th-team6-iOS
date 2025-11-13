//
//  SelfieFeedService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

protocol SelfieFeedService {
    func fetchFeeds(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResponseDTO
    func fetchFeedDetail(feedId: Int) async throws -> SelfieFeedDetailResponseDTO
    func sendReaction(feedId: Int, emojiType: String) async throws -> SelfieFeedReactionResponseDTO
    func createFeed(data: SelfieFeedCreateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedCreateResponseDTO
    func updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResponseDTO
    func deleteFeed(feedId: Int) async throws -> SelfieFeedDeleteResponseDTO
    func fetchWeeklySelfieCount(startDate: String, endDate: String) async throws -> SelfieWeekResponseDTO
    func fetchUsersByDate(date: String) async throws -> SelfieUsersByDateResponseDTO
    func checkUploadable(runSessionId: Int) async throws -> SelfieUploadableResponseDTO
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
    
    func fetchFeedDetail(feedId: Int) async throws -> SelfieFeedDetailResponseDTO {
        try await apiClient.request(
            FeedAPI.getFeedById(feedId: feedId),
            responseType: SelfieFeedDetailResponseDTO.self
        )
    }
    
    func sendReaction(feedId: Int, emojiType: String) async throws -> SelfieFeedReactionResponseDTO {
        try await apiClient.request(
            FeedAPI.postReaction(feedId: feedId, emojiType: emojiType),
            responseType: SelfieFeedReactionResponseDTO.self
        )
    }
    
    func createFeed(data: SelfieFeedCreateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedCreateResponseDTO {
        try await apiClient.request(
            FeedAPI.createFeed(data: data, selfieImage: selfieImage),
            responseType: SelfieFeedCreateResponseDTO.self
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
    
    func checkUploadable(runSessionId: Int) async throws -> SelfieUploadableResponseDTO {
        try await apiClient.request(
            FeedAPI.checkUploadable(runSessionId: runSessionId),
            responseType: SelfieUploadableResponseDTO.self
        )
    }
}
