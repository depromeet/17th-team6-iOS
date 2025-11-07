//
//  FriendRunningStatusUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation
import CoreLocation

protocol FriendRunningStatusUseCaseProtocol {
    func execute(page: Int, size: Int) async throws -> [FriendRunningStatus]
}

final class FriendRunningStatusUseCase: FriendRunningStatusUseCaseProtocol {
    private let repository: FriendRunningStatusRepository
    private let geocoder = CLGeocoder()
    
    init(repository: FriendRunningStatusRepository) {
        self.repository = repository
    }
    
    /// 서버로부터 친구 러닝 현황 조회
    func execute(page: Int, size: Int) async throws -> [FriendRunningStatus] {
        try await repository.fetchRunningStatuses(page: page, size: size)
    }
}

