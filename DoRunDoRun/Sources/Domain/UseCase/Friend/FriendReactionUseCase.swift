//
//  FriendReactionUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

protocol FriendReactionUseCaseProtocol {
    func sendReaction(to id: Int) async throws
}

final class FriendReactionUseCase: FriendReactionUseCaseProtocol {
    private let repository: FriendReactionRepository

    init(repository: FriendReactionRepository) {
        self.repository = repository
    }

    func sendReaction(to id: Int) async throws {
        try await repository.sendReaction(to: id)
    }
}
