//
//  FriendDeleteRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

final class FriendDeleteRepositoryImpl: FriendDeleteRepository {
    private let service: FriendService

    init(service: FriendService = FriendServiceImpl()) {
        self.service = service
    }

    func deleteFriends(ids: [Int]) async throws {
        _ = try await service.deleteFriends(ids: ids)
    }
}
