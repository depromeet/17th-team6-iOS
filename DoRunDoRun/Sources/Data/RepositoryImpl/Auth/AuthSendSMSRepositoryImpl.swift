//
//  AuthSendSMSRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

final class AuthSendSMSRepositoryImpl: AuthSendSMSRepository {
    private let service: AuthService

    init(service: AuthService = AuthServiceImpl()) {
        self.service = service
    }

    func sendSMS(phoneNumber: String) async throws {
        _ = try await service.sendSMS(phoneNumber: phoneNumber)
    }
}
