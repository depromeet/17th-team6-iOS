//
//  AuthVerifySMSRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

final class AuthVerifySMSRepositoryImpl: AuthVerifySMSRepository {
    private let service: AuthService

    init(service: AuthService = AuthServiceImpl()) {
        self.service = service
    }

    func verifySMS(phoneNumber: String, verificationCode: String) async throws -> PhoneVerificationResult {
        let dto = try await service.verifySMS(phoneNumber: phoneNumber, verificationCode: verificationCode)
        return dto.data.toDomain()
    }
}
