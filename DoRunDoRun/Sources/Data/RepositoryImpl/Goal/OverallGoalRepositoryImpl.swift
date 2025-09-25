//
//  OverallGoalRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

final class OverallGoalRepositoryImpl: OverallGoalRepository {
    private let service: OverallGoalServiceProtocol
    
    init(service: OverallGoalServiceProtocol = MockOverallGoalService()) {
        self.service = service
    }
    
    func getOverallGoal() async throws -> OverallGoal {
        let dto = try await service.fetchOverallGoal()
        return dto.toEntity()
    }
}
