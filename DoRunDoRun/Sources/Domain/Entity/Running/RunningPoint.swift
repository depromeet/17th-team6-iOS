//
//  RunningPoint.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

/// 사용자가 달린 경로를 구성하는 GPS 좌표 모델
struct RunningPoint {
    /// 해당 위치가 기록된 시각
    let timestamp: Date
    /// 해당 위치 좌표
    let coordinate: CLLocationCoordinate2D
}


