//
//  ManualSessionResponseDTO.swift
//  DoRunDoRun
//
//  Created by Claude on 2/19/26.
//

import Foundation

struct ManualSessionResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: ManualSessionDataDTO
}

struct ManualSessionDataDTO: Decodable, Equatable {
    let id: Int
    let createdAt: String
    let finishedAt: String
    let durationTotal: Int
    let distanceTotal: Int
    let paceAvg: Int
    let cadenceAvg: Int
}

// MARK: - Mapping to Domain
extension ManualSessionDataDTO {
    func toDomain() -> RunningSessionSummary {
        let parser = DateFormatterManager.shared
        
        return RunningSessionSummary(
            sessionId: id,
            createdAt: parser.isoDate(from: createdAt) ?? Date(),
            finishedAt: parser.isoDate(from: finishedAt) ?? Date(),
            totalDistanceMeters: Double(distanceTotal),
            totalDurationSeconds: durationTotal,
            avgPaceSecPerKm: Double(paceAvg),
            avgCadenceSpm: Double(cadenceAvg),
            isSelfied: false,
            mapImageURL: nil
        )
    }
}
