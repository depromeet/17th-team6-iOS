//
//  AuthSendSMSUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

protocol AuthSendSMSUseCaseProtocol {
    func execute(phoneNumber: String) async throws
}

final class AuthSendSMSUseCase: AuthSendSMSUseCaseProtocol {
    private let repository: AuthSendSMSRepository

    init(repository: AuthSendSMSRepository) {
        self.repository = repository
    }

    func execute(phoneNumber: String) async throws {
        try await repository.sendSMS(phoneNumber: phoneNumber)
    }
}
