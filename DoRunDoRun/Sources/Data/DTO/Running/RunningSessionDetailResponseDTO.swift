//
//  RunningSessionDetailResponseDTO.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

// MARK: - Response Root
struct RunningSessionDetailResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: RunningSessionDetailDataDTO
}

struct RunningSessionDetailDataDTO: Decodable {
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
    let feed: FeedDTO?
    let segments: [[SegmentPointDTO]]
}

struct FeedDTO: Decodable {
    let id: Int
    let mapImage: String?
    let selfieImage: String?
    let content: String?
    let createdAt: String
}

struct SegmentPointDTO: Decodable {
    let time: String
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let distance: Double
    let pace: Double
    let speed: Double
    let cadence: Double
}

// MARK: - Mapping to Domain
extension RunningSessionDetailDataDTO {
    func toDomain() -> RunningDetail {
        let parser = DateFormatterManager.shared
        
        // 모든 세그먼트를 평탄화하여 좌표 배열로 변환
        let allCoordinates = segments.flatMap { $0 }.map { point in
            RunningPoint(
                timestamp: parser.isoDate(from: point.time) ?? Date(),
                coordinate: RunningCoordinate(
                    latitude: point.latitude,
                    longitude: point.longitude
                ),
                altitude: point.altitude,
                speedMps: point.speed
            )
        }

        // 최대 페이스 지점
        let maxPacePoint = RunningPoint(
            timestamp: Date(),
            coordinate: RunningCoordinate(
                latitude: paceMaxLatitude,
                longitude: paceMaxLongitude
            ),
            altitude: 0.0,
            speedMps: 0.0
        )

        // Feed 매핑
        let feedSummary: FeedSummary? = feed.map { feedDTO in
            FeedSummary(
                id: feedDTO.id,
                mapImageURL: feedDTO.mapImage.flatMap { URL(string: $0) },
                selfieImageURL: feedDTO.selfieImage.flatMap { URL(string: $0) },
                content: feedDTO.content,
                createdAt: parser.isoDate(from: feedDTO.createdAt) ?? Date()
            )
        }

        return RunningDetail(
            sessionId: id,
            startedAt: parser.isoDate(from: createdAt) ?? Date(),
            finishedAt: parser.isoDate(from: finishedAt) ?? Date(),
            totalDistanceMeters: Double(distanceTotal),
            elapsed: .seconds(durationTotal),
            avgPaceSecPerKm: Double(paceAvg),
            avgCadenceSpm: Double(cadenceAvg),
            maxCadenceSpm: Double(cadenceMax),
            fastestPaceSecPerKm: Double(paceMax),
            coordinateAtmaxPace: maxPacePoint,
            coordinates: allCoordinates,
            mapImageData: nil,
            mapImageURL: mapImage.flatMap { URL(string: $0) },
            feed: feedSummary
        )
    }
}
