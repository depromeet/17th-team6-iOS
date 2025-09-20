//
//  LocationServiceProtocol.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

enum LocationServiceError: Error {
    case unavailable
    case notAuthorized
    case alreadyStreaming
    case runtimeError(Error)
}

protocol LocationServiceProtocol: AnyObject {
    /// CoreLocation 업데이트 스트림을 시작하고 비동기 시퀀스를 반환
    func startTracking() throws(LocationServiceError) -> AsyncThrowingStream<CLLocation, Error>
    func stopTracking()
}
