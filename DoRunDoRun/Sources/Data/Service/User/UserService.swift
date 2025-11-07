//
//  UserService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation

protocol UserService {
    func fetchProfile() async throws -> UserProfileResponseDTO
}

final class UserServiceImpl: UserService {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchProfile() async throws -> UserProfileResponseDTO {
        try await apiClient.request(
            UserAPI.fetchProfile,
            responseType: UserProfileResponseDTO.self
        )
    }
}
