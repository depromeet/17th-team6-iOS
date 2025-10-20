//
//  FriendService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation
import Alamofire

/// 친구 관련 네트워크 요청 인터페이스
protocol FriendService {
    func getRunningStatus(page: Int, size: Int) async throws -> FriendRunningStatusResponseDTO
    func postReaction(userId: Int) async throws -> FriendReactionResponseDTO
}

/// 실제 네트워크 요청 구현체
final class FriendServiceImpl: FriendService {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func getRunningStatus(page: Int, size: Int) async throws -> FriendRunningStatusResponseDTO {
        try await apiClient.request(
            FriendAPI.runningStatus(page: page, size: size),
            responseType: FriendRunningStatusResponseDTO.self
        )
    }

    func postReaction(userId: Int) async throws -> FriendReactionResponseDTO {
        try await apiClient.request(
            FriendAPI.reaction(userId: userId),
            responseType: FriendReactionResponseDTO.self
        )
    }
}
