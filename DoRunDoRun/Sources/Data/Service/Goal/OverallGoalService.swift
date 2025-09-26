//
//  OverallGoalService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

import Alamofire

protocol OverallGoalServiceProtocol {
    func fetchOverallGoal() async throws -> OverallGoalDTO
    func addOverallGoal(requestDTO: AddOverallGoalRequestDTO) async throws -> OverallGoalDTO
}

final class OverallGoalAPIService: OverallGoalServiceProtocol {
    func fetchOverallGoal() async throws -> OverallGoalDTO {
        let url = "https://api.example.com/api/goals/latest"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: OverallGoalResponseDTO.self) { response in
                    switch response.result {
                    case .success(let result):
                        continuation.resume(returning: result.data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func addOverallGoal(requestDTO: AddOverallGoalRequestDTO) async throws -> OverallGoalDTO {
        let url = "https://api.example.com/api/goals"
        let headers: HTTPHeaders = [
            "X-User-Id": requestDTO.userId,
            "Content-Type": "application/json"
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: requestDTO,
                       encoder: JSONParameterEncoder.default,
                       headers: headers)
                .validate()
                .responseDecodable(of: OverallGoalDTO.self) { response in
                    switch response.result {
                    case .success(let result):
                        continuation.resume(returning: result)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

final class MockOverallGoalService: OverallGoalServiceProtocol {
    func fetchOverallGoal() async throws -> OverallGoalDTO {
        return OverallGoalDTO(
            id: 1,
            createdAt: "2024-01-01T09:00:00Z",
            updatedAt: "2024-01-01T09:00:00Z",
            pausedAt: "2024-01-01T09:00:00Z",
            clearedAt: nil,
            title: "10km 마라톤 완주",
            subTitle: "초보 러너도 안정적으로 완주할 수 있어요!",
            type: "MARATHON",
            pace: 360,
            distance: 10000,
            duration: 60,
            currentRountCount: 4,
            totalRoundCount: 10
        )
    }
    
    func addOverallGoal(requestDTO: AddOverallGoalRequestDTO) async throws -> OverallGoalDTO {
        return OverallGoalDTO(
            id: 99,
            createdAt: "2025-09-26T09:00:00Z",
            updatedAt: "2025-09-26T09:00:00Z",
            pausedAt: nil,
            clearedAt: nil,
            title: requestDTO.title,
            subTitle: requestDTO.subTitle,
            type: requestDTO.type,
            pace: requestDTO.pace,
            distance: requestDTO.distance,
            duration: requestDTO.duration,
            currentRountCount: 0,
            totalRoundCount: requestDTO.totalRoundCount
        )
    }
}
