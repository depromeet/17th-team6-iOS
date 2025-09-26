//
//  SessionGoalRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

protocol SessionGoalRepository {
    func getSessionGoal() async throws -> SessionGoal
    func getSessionGoals() async throws -> [SessionGoal]
}
