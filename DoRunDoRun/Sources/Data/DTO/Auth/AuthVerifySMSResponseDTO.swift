//
//  AuthVerifySMSResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/27/25.
//

struct AuthVerifySMSResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: AuthVerifySMSDataDTO
}

struct AuthVerifySMSDataDTO: Decodable {
    let phoneNumber: String
    let isExistingUser: Bool
    let user: AuthUserDTO?
    let token: AuthTokenDTO?
}

struct AuthUserDTO: Decodable {
    let id: Int
    let nickname: String
}

struct AuthTokenDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Mapping to Domain
extension AuthVerifySMSDataDTO {
    func toDomain() -> PhoneVerificationResult {
        .init(
            phoneNumber: phoneNumber,
            isExistingUser: isExistingUser,
            user: user.map { User(id: $0.id, nickname: $0.nickname) },
            token: token.map { Token(accessToken: $0.accessToken, refreshToken: $0.refreshToken) }
        )
    }
}

