//
//  FriendReactionRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

/// 친구 응원하기 Repository 프로토콜의 실제 구현체
final class FriendReactionRepositoryImpl: FriendReactionRepository {
    private let service: FriendService

    init(service: FriendService = FriendServiceImpl()) {
        self.service = service
    }

    func sendReaction(to userId: Int) async throws {
        _ = try await service.postReaction(userId: userId)
    }
}
