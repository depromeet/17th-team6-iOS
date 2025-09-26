//
//  RecommendedGoalSelectWorker.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

import Foundation

final class RecommendedGoalSelectWorker {
    private let recommendedGoalRepository: RecommendedGoalRepository
    private let overallGoalRepository: OverallGoalRepository
    
    init(
        recommendedGoalRepository: RecommendedGoalRepository = RecommendedGoalRepositoryImpl(),
        overallGoalRepository: OverallGoalRepository = OverallGoalRepositoryImpl()
    ) {
        self.recommendedGoalRepository = recommendedGoalRepository
        self.overallGoalRepository = overallGoalRepository
    }
    
    func loadRecommendedGoals(goalOption: GoalOption) async throws -> [RecommendedGoal] {
        try await recommendedGoalRepository.getRecommendedGoals(goalOption: goalOption)
    }
    
    func addOverallGoal(entity: OverallGoal) async throws -> OverallGoal {
        try await overallGoalRepository.addOverallGoal(entity: entity)
    }
}
