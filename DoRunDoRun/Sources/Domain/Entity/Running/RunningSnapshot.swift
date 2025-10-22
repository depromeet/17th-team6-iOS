//
//  RunningSnapshot.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/21/25.
//

import Foundation

/// 화면/도메인에서 소비할 스냅샷(단일 순간)
struct RunningSnapshot {
    let timestamp: Date
    let lastPoint: RunningPoint?
    let metrics: RunningMetrics
}
