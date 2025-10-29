//
//  AuthService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/27/25.
//

import Foundation

protocol AuthService {
    func sendSMS(phoneNumber: String) async throws -> AuthSendSMSResponseDTO
}

final class AuthServiceImpl: AuthService {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func sendSMS(phoneNumber: String) async throws -> AuthSendSMSResponseDTO {
        try await apiClient.request(
            AuthAPI.sendSMS(phoneNumber: phoneNumber),
            responseType: AuthSendSMSResponseDTO.self
        )
    }
}
