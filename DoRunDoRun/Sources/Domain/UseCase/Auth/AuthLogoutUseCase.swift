//
//  AuthLogoutUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

protocol AuthLogoutUseCaseProtocol {
    func execute() async throws
}

final class AuthLogoutUseCase: AuthLogoutUseCaseProtocol {
    private let repository: AuthLogoutRepository

    init(repository: AuthLogoutRepository = AuthLogoutRepositoryImpl()) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.logout()
    }
}
