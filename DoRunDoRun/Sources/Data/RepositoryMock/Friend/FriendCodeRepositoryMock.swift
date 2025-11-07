//
//  FriendCodeRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

final class FriendCodeRepositoryMock: FriendCodeRepository {
    func addFriendByCode(_ code: String) async throws -> FriendCode {
        return FriendCode(userId: 123)
    }
}
