//
//  AuthService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/27/25.
//

import Foundation

protocol AuthService {
    func sendSMS(phoneNumber: String) async throws -> AuthSendSMSResponseDTO
    func verifySMS(phoneNumber: String, verificationCode: String) async throws -> AuthVerifySMSResponseDTO
    func signup(request: AuthSignupRequestDTO, profileImageData: Data?) async throws -> AuthSignupResponseDTO
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

    func verifySMS(phoneNumber: String, verificationCode: String) async throws -> AuthVerifySMSResponseDTO {
        try await apiClient.request(
            AuthAPI.verifySMS(phoneNumber: phoneNumber, verificationCode: verificationCode),
            responseType: AuthVerifySMSResponseDTO.self
        )
    }
    
    func signup(request: AuthSignupRequestDTO, profileImageData: Data?) async throws -> AuthSignupResponseDTO {
        try await apiClient.request(
            AuthAPI.signup(request: request, profileImageData: profileImageData),
            responseType: AuthSignupResponseDTO.self
        )
    }
}
