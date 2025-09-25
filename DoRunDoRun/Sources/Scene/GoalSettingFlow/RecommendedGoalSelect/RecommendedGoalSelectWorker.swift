//
//  RecommendedGoalSelectWorker.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

import Foundation

final class RecommendedGoalSelectWorker {
    private let repository: RecommendedGoalRepository
    
    init(repository: RecommendedGoalRepository = RecommendedGoalRepositoryImpl()) {
        self.repository = repository
    }
    
    func loadRecommendedGoals(goalOption: GoalOption) async throws -> [RecommendedGoal] {
        try await repository.getRecommendedGoals(goalOption: goalOption)
    }
}
