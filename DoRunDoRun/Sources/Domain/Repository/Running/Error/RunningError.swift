//
//  RunningError.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/26/25.
//

/// Repository가 외부로 노출하는 도메인 에러
enum RunningError: Error {
    case locationNotAuthorized
    case motionNotAuthorized
    case sensorUnavailable
    case alreadyRunning
    case invalidState
    case runtime(Error)   // 원인 보존
}
