//
//  CoreLocation+Domain.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func toRunningCoordinate() -> RunningCoordinate {
        RunningCoordinate(
            latitude: Double(latitude),
            longitude: Double(longitude)
        )
    }
}

extension CLLocation {
    func toRunningPoint() -> RunningPoint {
        RunningPoint(
            timestamp: timestamp,
            coordinate: coordinate.toRunningCoordinate(),
            altitude: altitude,
            speedMps: speed > 0 ? speed : 0
        )
    }
}
