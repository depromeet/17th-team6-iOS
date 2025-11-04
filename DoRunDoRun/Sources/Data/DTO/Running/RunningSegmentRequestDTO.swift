//
//  RunningSegmentRequestDTO.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

struct RunningSegmentRequestDTO: Encodable {
    let segments: [SegmentDTO]
    let isStopped: Bool
}

struct SegmentDTO: Encodable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let speed: Double
    let pace: Int  // 초/킬로미터
    let cadence: Int  // steps per minute
    let distance: Int  // 미터
    let time: String  // ISO8601 형식
}

// MARK: - Domain to DTO Mapping
extension SegmentDTO {
    init(from point: RunningPoint, distance: Double, pace: Double, cadence: Double) {
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        self.latitude = point.coordinate.latitude
        self.longitude = point.coordinate.longitude
        self.altitude = point.altitude
        self.speed = point.speedMps
        self.pace = Int(pace)
        self.cadence = Int(cadence)
        self.distance = Int(distance)
        self.time = iso8601Formatter.string(from: point.timestamp)
    }
}
