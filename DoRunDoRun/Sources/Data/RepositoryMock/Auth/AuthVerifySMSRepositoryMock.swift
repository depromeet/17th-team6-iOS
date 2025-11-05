//
//  AuthVerifySMSRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

final class AuthVerifySMSRepositoryMock: AuthVerifySMSRepository {
    func verifySMS(phoneNumber: String, verificationCode: String) async throws -> PhoneVerificationResult {
        print("[Mock] 인증번호 검증 성공: \(phoneNumber), code: \(verificationCode)")
        
        // 더미 유저 & 토큰 생성
        let dummyUser = User(id: 1, nickname: "MockUser")
        let dummyToken = Token(accessToken: "mock_access_token", refreshToken: "mock_refresh_token")

        return PhoneVerificationResult(
            phoneNumber: phoneNumber,
            isExistingUser: false,
            user: dummyUser,
            token: dummyToken
        )
    }
}
