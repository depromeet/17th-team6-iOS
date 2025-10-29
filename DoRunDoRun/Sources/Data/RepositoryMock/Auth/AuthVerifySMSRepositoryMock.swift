//
//  AuthVerifySMSRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

final class AuthVerifySMSRepositoryMock: AuthVerifySMSRepository {
    func verifySMS(phoneNumber: String, verificationCode: String) async throws -> PhoneVerificationResult {
        print("[Mock] 인증번호 검증 성공: \(phoneNumber), code: \(verificationCode)")
        return PhoneVerificationResult(
            phoneNumber: phoneNumber,
            isExistingUser: false,
            user: nil,
            token: nil
        )
    }
}
