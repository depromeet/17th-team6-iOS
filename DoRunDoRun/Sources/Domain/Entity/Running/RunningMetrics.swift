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
}
