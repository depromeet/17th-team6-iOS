//
//  AuthWithdrawRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

final class AuthWithdrawRepositoryImpl: AuthWithdrawRepository {
    private let service: AuthService

    init(service: AuthService = AuthServiceImpl()) {
        self.service = service
    }

    func withdraw() async throws {
        _ = try await service.withdraw()
    }
}
