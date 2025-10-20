//
//  FriendReactionRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

/// 친구 응원하기 Repository 프로토콜의 Mock 구현체
final class FriendReactionRepositoryMock: FriendReactionRepository {
    func sendReaction(to userId: Int) async throws {
        print("[Mock] \(userId)번 친구에게 응원 전송 성공")
    }
}
