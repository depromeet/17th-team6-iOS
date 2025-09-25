//
//  HomeWorker.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

final class HomeWorker {
    private let overallGoalRepository: OverallGoalRepository
    private let sessionGoalRepository: SessionGoalRepository
    
    init(
        overallGoalRepository: OverallGoalRepository = OverallGoalRepositoryImpl(),
        sessionGoalRepository: SessionGoalRepository = SessionGoalRepositoryImpl()
    ) {
        self.overallGoalRepository = overallGoalRepository
        self.sessionGoalRepository = sessionGoalRepository
    }
    
    func loadOverallGoal() async throws -> OverallGoal {
        try await overallGoalRepository.getOverallGoal()
    }
    
    func loadSessionGoal() async throws -> SessionGoal {
        try await sessionGoalRepository.getSessionGoal()
    }
}

