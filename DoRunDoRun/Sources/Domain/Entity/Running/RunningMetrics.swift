//
//  RunningMetrics.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/21/25.
//

import Foundation

/// 런닝 누적 지표
struct RunningMetrics: Equatable {
    /// 누적 이동거리 (m)
    let totalDistanceMeters: Double
    /// 누적 경과시간 (일시정지 제외)
    let elapsed: Duration
    /// 현재 페이스 (초/킬로미터)
    let currentPaceSecPerKm: Double
    /// 현재 케이던스 (steps/min)
    let currentCadenceSpm: Double
}
