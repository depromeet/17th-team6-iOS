//
//  AuthVerifySMSUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

protocol AuthVerifySMSUseCaseProtocol {
    func execute(phoneNumber: String, verificationCode: String) async throws -> PhoneVerificationResult
}

final class AuthVerifySMSUseCase: AuthVerifySMSUseCaseProtocol {
    private let repository: AuthVerifySMSRepository

    init(repository: AuthVerifySMSRepository) {
        self.repository = repository
    }

    func execute(phoneNumber: String, verificationCode: String) async throws -> PhoneVerificationResult {
        try await repository.verifySMS(phoneNumber: phoneNumber, verificationCode: verificationCode)
    }
}
