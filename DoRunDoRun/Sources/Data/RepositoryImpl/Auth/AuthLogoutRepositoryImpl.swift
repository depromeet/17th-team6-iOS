//
//  AuthLogoutRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

final class AuthLogoutRepositoryImpl: AuthLogoutRepository {
    private let service: AuthService

    init(service: AuthService = AuthServiceImpl()) {
        self.service = service
    }

    func logout() async throws {
        _ = try await service.logout()
    }
}
