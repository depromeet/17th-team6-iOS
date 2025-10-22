//
//  RunningPoint.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/21/25.
//

import Foundation

/// 도메인 좌표 타입
struct RunningCoordinate {
    let latitude: Double
    let longitude: Double
}

/// 런닝 경로의 한 지점
struct RunningPoint {
    let timestamp: Date
    let coordinate: RunningCoordinate
    let altitude: Double
    let speedMps: Double
}
