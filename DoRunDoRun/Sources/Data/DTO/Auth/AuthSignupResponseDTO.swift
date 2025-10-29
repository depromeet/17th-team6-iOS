//
//  AuthSignupResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

struct AuthSignupResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: AuthSignupDataDTO
}

struct AuthSignupDataDTO: Decodable {
    let user: AuthUserDTO
    let token: AuthTokenDTO
}

extension AuthSignupDataDTO {
    func toDomain() -> SignupResult {
        SignupResult(
            user: User(id: user.id, nickname: user.nickname),
            token: Token(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken
            )
        )
    }
}
