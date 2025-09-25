//
//  SessionGoalDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

struct SessionGoalResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: SessionGoalDTO
}

struct SessionGoalsResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: DataContainer
    
    struct DataContainer: Decodable {
        let contents: [SessionGoalDTO]
        let meta: Meta
    }
    
    struct Meta: Decodable {
        let page: Int
        let size: Int
        let totalElements: Int
        let totalPages: Int
        let first: Bool
        let last: Bool
        let hasNext: Bool
        let hasPrevious: Bool
    }
}

struct SessionGoalDTO: Decodable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let clearedAt: String?
    let goalId: Int
    let pace: Int
    let distance: Int
    let duration: Int
    let roundCount: Int
}

extension SessionGoalDTO {
    func toEntity() -> SessionGoal {
        let formatter = ISO8601DateFormatter()
        return SessionGoal(
            id: id,
            createdAt: formatter.date(from: createdAt) ?? Date(),
            updatedAt: formatter.date(from: updatedAt) ?? Date(),
            clearedAt: clearedAt.flatMap { formatter.date(from: $0) },
            goalId: goalId,
            pace: pace,
            distance: distance,
            duration: duration,
            roundCount: roundCount
        )
    }
}
