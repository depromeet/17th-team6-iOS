//
//  FriendCodeRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

final class FriendCodeRepositoryImpl: FriendCodeRepository {
    private let service: FriendService

    init(service: FriendService = FriendServiceImpl()) {
        self.service = service
    }

    func addFriendByCode(_ code: String) async throws -> FriendCode {
        let response = try await service.addFriendByCode(code: code)
        return FriendCode(userId: response.data.userId)
    }
}
