//
//  SessionGoalService.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

import Alamofire

protocol SessionGoalServiceProtocol {
    func fetchSessionGoal() async throws -> SessionGoalDTO
    func fetchSessionGoals() async throws -> [SessionGoalDTO]
}

final class SessionGoalService: SessionGoalServiceProtocol {
    func fetchSessionGoal() async throws -> SessionGoalDTO {
        let url = "https://api.example.com/api/goals/plans/imminent"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: SessionGoalResponseDTO.self) { response in
                    switch response.result {
                    case .success(let result):
                        continuation.resume(returning: result.data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func fetchSessionGoals() async throws -> [SessionGoalDTO] {
        let url = "https://api.example.com/session-goals"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: SessionGoalsResponseDTO.self) { response in
                    switch response.result {
                    case .success(let result):
                        continuation.resume(returning: result.data.contents)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

final class MockSessionGoalService: SessionGoalServiceProtocol {
    func fetchSessionGoal() async throws -> SessionGoalDTO {
        return SessionGoalDTO(
            id: 1,
            createdAt: "2024-01-01T09:00:00Z",
            updatedAt: "2024-01-01T09:00:00Z",
            clearedAt: nil,
            goalId: 1,
            pace: 360,
            distance: 5000,
            duration: 60,
            roundCount: 5
        )
    }
    
    func fetchSessionGoals() async throws -> [SessionGoalDTO] {
        return [
            SessionGoalDTO(
                id: 1,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 1
            ),
            SessionGoalDTO(
                id: 2,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 2
            ),
            SessionGoalDTO(
                id: 3,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 3
            ),
            SessionGoalDTO(
                id: 4,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 4
            ),
            SessionGoalDTO(
                id: 5,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 5
            ),
            SessionGoalDTO(
                id: 6,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 6
            ),
            SessionGoalDTO(
                id: 7,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 7
            ),
            SessionGoalDTO(
                id: 8,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 8
            ),
            SessionGoalDTO(
                id: 9,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 9
            ),
            SessionGoalDTO(
                id: 10,
                createdAt: "2024-01-01T09:00:00Z",
                updatedAt: "2024-01-01T09:00:00Z",
                clearedAt: nil,
                goalId: 1,
                pace: 360,
                distance: 1000,
                duration: 30,
                roundCount: 10
            ),
        ]
    }
}

