//
//  RecommendedGoalRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

import Foundation

final class RecommendedGoalRepositoryImpl: RecommendedGoalRepository {
    private let service: RecommendedGoalServiceProtocol
    
    init(service: RecommendedGoalServiceProtocol = RecommendedGoalService()) {
        self.service = service
    }
    
    func getRecommendedGoals(goalOption: GoalOption) async throws -> [RecommendedGoal] {
        let dtos = try await service.fetchRecommendedGoals(goalOption: goalOption)
        return dtos.map { $0.toEntity() }
    }
}
