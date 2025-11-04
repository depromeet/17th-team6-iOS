//
//  RunningSnapshotViewState.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/22/25.
//

struct RunningSnapshotViewState: Equatable, Sendable {
    let distanceText: String
    let paceText: String
    let durationText: String
    let cadenceText: String
    let lastCoordinate: RunningCoordinateViewState?
}
