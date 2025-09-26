//
//  OverallGoalDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

struct OverallGoalResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: OverallGoalDTO
}

struct OverallGoalDTO: Decodable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let pausedAt: String?
    let clearedAt: String?
    let title: String
    let subTitle: String
    let type: String
    let pace: Int
    let distance: Int
    let duration: Int
    let currentRountCount: Int
    let totalRoundCount: Int
}

extension OverallGoalDTO {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    func toEntity() -> OverallGoal {
        return OverallGoal(
            id: id,
            createdAt: Self.isoFormatter.date(from: createdAt) ?? Date(),
            updatedAt: Self.isoFormatter.date(from: updatedAt) ?? Date(),
            pausedAt: pausedAt.flatMap { Self.isoFormatter.date(from: $0) },
            clearedAt: clearedAt.flatMap { Self.isoFormatter.date(from: $0) },
            title: title,
            subTitle: subTitle,
            type: type,
            pace: pace,
            distance: distance,
            duration: duration,
            currentRoundCount: currentRountCount,
            totalRoundCount: totalRoundCount
        )
    }
}
