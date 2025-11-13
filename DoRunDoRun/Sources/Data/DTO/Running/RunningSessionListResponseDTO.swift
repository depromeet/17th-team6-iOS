//
//  RunningSessionListResponseDTO.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

// MARK: - Response Root
struct RunningSessionListResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: [RunningSessionSummaryDTO]
}

struct RunningSessionSummaryDTO: Decodable {
    let runSessionId: Int
    let createdAt: String
    let updatedAt: String
    let finishedAt: String
    let distanceTotal: Int
    let durationTotal: Int
    let paceAvg: Int
    let cadenceAvg: Int
    let isSelfied: Bool
    let mapImage: String?
}

// MARK: - Mapping to Domain
extension RunningSessionSummaryDTO {
    func toDomain() -> RunningSessionSummary {
        let parser = DateFormatterManager.shared

        return RunningSessionSummary(
            sessionId: runSessionId,
            createdAt: parser.isoDate(from: createdAt) ?? Date(),
            finishedAt: parser.isoDate(from: finishedAt) ?? Date(),
            totalDistanceMeters: Double(distanceTotal),
            totalDurationSeconds: durationTotal,
            avgPaceSecPerKm: Double(paceAvg),
            avgCadenceSpm: Double(cadenceAvg),
            isSelfied: isSelfied,
            mapImageURL: mapImage.flatMap { URL(string: $0) }
        )
    }
}

