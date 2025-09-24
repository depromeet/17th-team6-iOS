//
//  RecommendedGoalService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

import Foundation

import Alamofire

protocol RecommendedGoalServiceProtocol {
    func fetchRecommendedGoals(goalOption: GoalOption) async throws -> [RecommendedGoalDTO]
}

/// 실제 서버 통신
final class RecommendedGoalService: RecommendedGoalServiceProtocol {
    func fetchRecommendedGoals(goalOption: GoalOption) async throws -> [RecommendedGoalDTO] {
        let url = "https://api.example.com/api/goals/suggest"
        let parameters: [String: Any] = [
            "type": goalOption.type.rawValue,
            "distance": goalOption.distance,
            "duration": goalOption.duration,
            "pace": goalOption.pace
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: ["Content-Type": "application/json"])
            .validate()
            .responseDecodable(of: RecommendedGoalResponseDTO.self) { response in
                switch response.result {
                case .success(let result):
                    continuation.resume(returning: result.data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

/// 목 데이터
final class MockRecommendedGoalService: RecommendedGoalServiceProtocol {
    func fetchRecommendedGoals(goalOption: GoalOption) async throws -> [RecommendedGoalDTO] {
        switch goalOption.type {
        case .marathon: [
            RecommendedGoalDTO(
                type: "MARATHON",
                title: "10km 마라톤 완주",
                subTitle: "초보 러너도 안정적으로 완주할 수 있어요!",
                distance: 10000,
                totalRoundCount: 8,
                duration: 60,
                pace: 390,
                isRecommended: true
            ),
            RecommendedGoalDTO(
                type: "MARATHON",
                title: "하프마라톤 완주",
                subTitle: "한계를 넘어서는 도전, 함께 성장해봐요!",
                distance: 21097,
                totalRoundCount: 12,
                duration: 200,
                pace: 360,
                isRecommended: false
            ),
            RecommendedGoalDTO(
                type: "MARATHON",
                title: "풀마라톤 완주",
                subTitle: "러너라면 한 번쯤 꿈꾸는 목표에 도전해보세요!",
                distance: 42195,
                totalRoundCount: 16,
                duration: 280,
                pace: 390,
                isRecommended: false
            )
        ]
        case .stamina: [
            RecommendedGoalDTO(
                type: "STAMINA",
                title: "30분 달리기",
                subTitle: "러닝의 첫걸음, 체력을 기르는 기본 루틴",
                distance: 5000,
                totalRoundCount: 10,
                duration: 30,
                pace: 420,
                isRecommended: true
            )
        ]
        case .zone2: [
            RecommendedGoalDTO(
                type: "ZONE_2",
                title: "Zone2 러닝 - 5km",
                subTitle: "편안한 조깅으로 지방 연소",
                distance: 5000,
                totalRoundCount: 6,
                duration: 40,
                pace: 390,
                isRecommended: true
            )
        ]
        }
    }
}
