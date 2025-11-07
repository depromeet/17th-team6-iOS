//
//  FriendDeleteRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

protocol FriendDeleteRepository {
    func deleteFriends(ids: [Int]) async throws -> FriendDeleteResult
}
