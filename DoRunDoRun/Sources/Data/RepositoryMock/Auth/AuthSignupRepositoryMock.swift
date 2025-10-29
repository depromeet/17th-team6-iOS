//
//  AuthSignupRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import Foundation

final class AuthSignupRepositoryMock: AuthSignupRepository {
    func signup(
        request: AuthSignupRequestDTO,
        profileImageData: Data?
    ) async throws -> SignupResult {
        print("""
        [Mock] 회원가입 요청:
        - phoneNumber: \(request.phoneNumber)
        - nickname: \(request.nickname)
        - marketingConsentAt: \(request.consent.marketingConsentAt ?? "nil")
        - locationConsentAt: \(request.consent.locationConsentAt)
        - personalConsentAt: \(request.consent.personalConsentAt)
        - deviceToken: \(request.deviceToken)
        - profileImage: \(profileImageData != nil ? "✅ 있음" : "❌ 없음")
        """)

        // 서버 응답 모킹
        return SignupResult(
            user: User(id: 1, nickname: request.nickname),
            token: Token(accessToken: "mockAccessToken", refreshToken: "mockRefreshToken")
        )
    }
}
