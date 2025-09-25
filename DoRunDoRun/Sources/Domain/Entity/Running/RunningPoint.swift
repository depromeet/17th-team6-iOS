//
//  RunningPoint.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/26/25.
//

import Foundation

/// 런닝 경로의 한 지점
struct RunningPoint {
    let timestamp: Date
    let coordinate: RunningCoordinate
    let altitude: Double
    let speedMps: Double
}

/// 도메인 좌표 타입
struct RunningCoordinate {
    let latitude: Double
    let longitude: Double
}
