//
//  RunnningSummary.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/31/25.
//

import Foundation

struct RunningSummary {
    /// 누적 이동거리 (m)
    let totalDistanceMeters: Double
    /// 누적 경과시간 (일시정지 제외)
    let elapsed: Duration
    /// 평균 페이스 (초/킬로미터)
    let avgPaceSecPerKm: Double
    /// 평균 케이던스 (steps/min)
    let avgCadenceSpm: Double
    /// 최대 케이던스 (steps/min)
    let maxCadenceSpm: Double
    /// 최대 페이스 (초/킬로미터, 작을수록 빠름)
    let fastestPaceSecPerKm: Double
    /// 최대 페이스 시점의 좌표 정보
    let coordinateAtmaxPace: RunningPoint
}

#if DEBUG
extension RunningSummary {
    static let mock = RunningSummary(
        totalDistanceMeters: 3210.5,
        elapsed: .seconds(900), // 15분
        avgPaceSecPerKm: 280.0, // 약 4분40초/km
        avgCadenceSpm: 175.0,
        maxCadenceSpm: 186.0,
        fastestPaceSecPerKm: 265.0,
        coordinateAtmaxPace: RunningPoint(
            timestamp: Date(),
            coordinate: RunningCoordinate(latitude: 37.5465, longitude: 127.0652),
            altitude: 25.0,
            speedMps: 3.8
        )
    )
}
#endif
