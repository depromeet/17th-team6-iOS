//
//  FriendReactionRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

/// 친구 응원하기 Repository
protocol FriendReactionRepository {
    func sendReaction(to userId: Int) async throws
}
