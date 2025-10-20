//
//  FriendRunningStatusRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

/// 유저 및 친구 러닝 상태 Repository 프로토콜의 실제 구현체
final class FriendRunningStatusRepositoryImpl: FriendRunningStatusRepository {
    private let service: FriendService

    init(service: FriendService = FriendServiceImpl()) {
        self.service = service
    }

    func fetchRunningStatuses(page: Int, size: Int) async throws -> [FriendRunningStatus] {
        let response = try await service.getRunningStatus(page: page, size: size)
        return response.data.contents.map { $0.toDomain() }
    }
}
