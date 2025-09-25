//
//  RecommendedGoalDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

import Foundation

struct RecommendedGoalResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: [RecommendedGoalDTO]
}

struct RecommendedGoalDTO: Decodable {
    let type: String
    let title: String
    let subTitle: String
    let distance: Int
    let totalRoundCount: Int
    let duration: Int
    let pace: Int
    let isRecommended: Bool
}

// DTO -> Entity 변환
extension RecommendedGoalDTO {
    func toEntity() -> RecommendedGoal {
        return RecommendedGoal(
            type: type,
            title: title,
            subTitle: subTitle,
            distance: distance,
            totalRoundCount: totalRoundCount,
            duration: duration,
            pace: pace,
            isRecommended: isRecommended
        )
    }
}
