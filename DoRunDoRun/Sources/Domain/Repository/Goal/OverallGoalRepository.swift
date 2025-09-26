//
//  OverallGoalRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

protocol OverallGoalRepository {
    func getOverallGoal() async throws -> OverallGoal
    func addOverallGoal(entity: OverallGoal) async throws -> OverallGoal
}
