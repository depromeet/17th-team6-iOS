//
//  OverallGoalListWorker.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

final class OverallGoalListWorker {
    private let repository: SessionGoalRepository
    
    init(repository: SessionGoalRepository = SessionGoalRepositoryImpl()) {
        self.repository = repository
    }
    
    func loadSessionGoals() async throws -> [SessionGoal] {
        try await repository.getSessionGoals()
    }
}
