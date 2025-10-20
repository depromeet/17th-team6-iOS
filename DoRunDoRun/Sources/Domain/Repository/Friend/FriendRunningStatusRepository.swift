//
//  FriendRunningStatusRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

/// 유저 및 친구 러닝 상태 Repository
protocol FriendRunningStatusRepository {
    func fetchRunningStatuses(page: Int, size: Int) async throws -> [FriendRunningStatus]
}
