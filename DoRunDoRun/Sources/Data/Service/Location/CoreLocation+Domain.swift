//
//  CoreLocation+Domain.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

extension CLLocation {
    func toDomain() -> RunningPoint {
        .init(
            timestamp: self.timestamp,
            coordinate: self.coordinate
        )
    }
}
