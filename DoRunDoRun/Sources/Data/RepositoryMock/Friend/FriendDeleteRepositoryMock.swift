//
//  FriendDeleteRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

final class FriendDeleteRepositoryMock: FriendDeleteRepository {
    func deleteFriends(ids: [Int]) async throws {
        print("[Mock] 친구 삭제 요청 완료 → 삭제된 ID: \(ids)")
    }
}
