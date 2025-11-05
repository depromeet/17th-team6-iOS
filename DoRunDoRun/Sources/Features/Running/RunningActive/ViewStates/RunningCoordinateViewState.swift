//
//  RunningCoordinateViewState.swift
//  
//
//  Created by zaehorang on 11/2/25.
//


struct RunningCoordinateViewState: Equatable, Sendable {
    let latitude: Double
    let longitude: Double
    let paceSecPerKm: Double  // 페이스 (초/km)
}