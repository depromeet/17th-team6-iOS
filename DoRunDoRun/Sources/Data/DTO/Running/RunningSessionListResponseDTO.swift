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
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return RunningSessionSummary(
            sessionId: runSessionId,
            createdAt: iso8601Formatter.date(from: createdAt) ?? Date(),
            finishedAt: iso8601Formatter.date(from: finishedAt) ?? Date(),
            totalDistanceMeters: Double(distanceTotal),
            totalDurationSeconds: durationTotal,
            avgPaceSecPerKm: Double(paceAvg),
            avgCadenceSpm: Double(cadenceAvg),
            isSelfied: isSelfied,
            mapImageURL: mapImage.flatMap { URL(string: $0) }
        )
    }
}
