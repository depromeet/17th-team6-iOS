//
//  RunningCompleteResponseDTO.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

// MARK: - Response Root
struct RunningCompleteResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: RunningCompleteDataDTO
}

struct RunningCompleteDataDTO: Decodable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let finishedAt: String
    let distanceTotal: Int
    let durationTotal: Int
    let paceAvg: Int
    let paceMax: Int
    let paceMaxLatitude: Double
    let paceMaxLongitude: Double
    let cadenceAvg: Int
    let cadenceMax: Int
    let mapImage: String?
}
