//
//  FriendDeleteUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

protocol FriendDeleteUseCaseProtocol {
    func execute(ids: [Int]) async throws -> FriendDeleteResult
}

final class FriendDeleteUseCase: FriendDeleteUseCaseProtocol {
    private let repository: FriendDeleteRepository

    init(repository: FriendDeleteRepository = FriendDeleteRepositoryImpl()) {
        self.repository = repository
    }

    func execute(ids: [Int]) async throws -> FriendDeleteResult {
        try await repository.deleteFriends(ids: ids)
    }
}
