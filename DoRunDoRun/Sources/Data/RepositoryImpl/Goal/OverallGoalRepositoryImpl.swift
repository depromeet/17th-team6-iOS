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
    
    func addOverallGoal(entity: OverallGoal) async throws -> OverallGoal {
        let requestDTO = AddOverallGoalRequestDTO(
            userId: "USER_ID", // 실제로는 AuthManager 등에서 가져오기
            title: entity.title,
            subTitle: entity.subTitle,
            type: entity.type,
            pace: entity.pace,
            distance: entity.distance,
            duration: entity.duration,
            totalRoundCount: entity.totalRoundCount
        )
        let dto = try await service.addOverallGoal(requestDTO: requestDTO)
        return dto.toEntity()
    }
}
