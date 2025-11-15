//
//  RunningSessionSummary.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

/// 러닝 세션 목록 조회용 요약 정보
struct RunningSessionSummary: Equatable {
    let sessionId: Int
    let createdAt: Date
    let finishedAt: Date
    let totalDistanceMeters: Double
    let totalDurationSeconds: Int
    let avgPaceSecPerKm: Double
    let avgCadenceSpm: Double
    let isSelfied: Bool
    let mapImageURL: URL?
}

extension RunningSessionSummary {
    static let mock = RunningSessionSummary(
        sessionId: 1,
        createdAt: Date(),
        finishedAt: Date().addingTimeInterval(1800),
        totalDistanceMeters: 5000,
        totalDurationSeconds: 1800,
        avgPaceSecPerKm: 360,
        avgCadenceSpm: 170,
        isSelfied: false,
        mapImageURL: URL(string: "https://example.com/map.jpg")
    )
}
