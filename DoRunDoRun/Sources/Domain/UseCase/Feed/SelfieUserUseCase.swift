//
//  SelfieUserUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

protocol SelfieUserUseCaseProtocol {
    func execute(date: String) async throws -> [SelfieUserResult]
}

struct SelfieUserUseCase: SelfieUserUseCaseProtocol {
    private let repository: SelfieUserRepository
    
    init(repository: SelfieUserRepository) {
        self.repository = repository
    }

    func execute(date: String) async throws -> [SelfieUserResult] {
        try await repository.fetchUsersByDate(date: date)
    }
}
