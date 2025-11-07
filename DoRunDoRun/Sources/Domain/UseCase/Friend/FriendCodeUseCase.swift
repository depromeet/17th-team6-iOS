//
//  FriendCodeUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

protocol FriendCodeUseCaseProtocol {
    func execute(_ code: String) async throws -> FriendCode
}

final class FriendCodeUseCase: FriendCodeUseCaseProtocol {
    private let repository: FriendCodeRepository

    init(repository: FriendCodeRepository = FriendCodeRepositoryImpl()) {
        self.repository = repository
    }

    func execute(_ code: String) async throws -> FriendCode {
        try await repository.addFriendByCode(code)
    }
}
