//
//  RunningProgress.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import Foundation

/// 실시간 달리기 진행 상태를 나타내는 모델
struct RunningProgress {
    /// 현재까지 이동 거리 (미터 단위)
    var currentDistance: Double
    /// 달리기 시작 이후 경과 시간 (초 단위)
    var elapsed: TimeInterval
    /// 평균 페이스 (1km를 달리는 데 걸린 시간, 초/킬로미터)
    var averagePace: Double
    /// 누적 걸음 수
    var totalSteps: Int
}
