//
//  AuthWithdrawUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

protocol AuthWithdrawUseCaseProtocol {
    func execute() async throws
}

final class AuthWithdrawUseCase: AuthWithdrawUseCaseProtocol {
    private let repository: AuthWithdrawRepository

    init(repository: AuthWithdrawRepository = AuthWithdrawRepositoryImpl()) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.withdraw()
    }
}
