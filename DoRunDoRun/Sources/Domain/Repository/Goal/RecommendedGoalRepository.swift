//
//  RecommendedGoalRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

import Foundation

protocol RecommendedGoalRepository {
    func getRecommendedGoals(goalOption: GoalOption) async throws -> [RecommendedGoal]
}
