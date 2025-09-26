//
//  SessionGoalRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

final class SessionGoalRepositoryImpl: SessionGoalRepository {
    private let service: SessionGoalServiceProtocol
    
    init(service: SessionGoalServiceProtocol = MockSessionGoalService()) {
        self.service = service
    }
    
    func getSessionGoal() async throws -> SessionGoal {
        let dto = try await service.fetchSessionGoal()
        return dto.toEntity()
    }
    
    func getSessionGoals() async throws -> [SessionGoal] {
        let dtos = try await service.fetchSessionGoals()
        return dtos.map { $0.toEntity() }
    }
}
