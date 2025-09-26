//
//  RunningMetrics.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/26/25.
//

/// 런닝 누적 지표
struct RunningMetrics {
    /// 누적 이동거리 (m)
    let totalDistanceMeters: Double
    /// 누적 경과시간 (일시정지 제외)
    let elapsed: Duration
    /// 평균 페이스 (초/킬로미터)
    let avgPaceSecPerKm: Double
    /// 현재 케이던스 (steps/min)
    let cadenceSpm: Double

    func toViewModel() -> RunningMetricsViewModel {
        let distanceKm = totalDistanceMeters / 1000
        let distanceStr = String(format: "%.1f km", distanceKm)

        let elapsedStr = elapsed.formatted()

        let paceMin = Int(avgPaceSecPerKm) / 60
        let paceSec = Int(avgPaceSecPerKm) % 60
        let paceStr = String(format: "%d'%02d\"", paceMin, paceSec)

        let cadenceStr = String(format: "%.0f", cadenceSpm)
        return .init(
            distance: distanceStr,
            elapsed: elapsedStr,
            pace: paceStr,
            cadence: cadenceStr
        )
    }
}

struct RunningMetricsViewModel {
    let distance: String
    let elapsed: String
    let pace: String  // e.g. 5'30"
    let cadence: String
}
