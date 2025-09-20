//  MotionServiceProtocol.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/14/25.
//

import CoreMotion

enum MotionServiceError: Error {
    case unavailable
    case notAuthorized
    case alreadyStreaming
    case runtimeError(Error)
}

// MARK: - MotionServiceProtocol
protocol MotionServiceProtocol: AnyObject {
    /// CoreMotion 업데이트 스트림을 시작하고 비동기 시퀀스를 반환
    func startTracking() throws(MotionServiceError) -> AsyncThrowingStream<CMPedometerData, Error>
    func stopTracking()
}
