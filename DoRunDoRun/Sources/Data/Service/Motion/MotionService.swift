//
//  MotionService.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/21/25.
//

import CoreMotion

enum MotionServiceError: Error {
    case unavailable
    case notAuthorized
    case alreadyStreaming
    case runtimeError(Error)
}

/// 사용자 움직임 데이터 수집 관련 인터페이스
protocol MotionService: AnyObject {
    /// CoreMotion 업데이트 스트림을 시작하고 비동기 시퀀스를 반환
    func startTracking() throws(MotionServiceError) -> AsyncThrowingStream<CMPedometerData, Error>
    func stopTracking()
}

/// MotionService 인터페이스 구현체
final class MotionServiceImpl: MotionService {
    private let pedometer = CMPedometer()
    
    private var continuation: AsyncThrowingStream<CMPedometerData, Error>.Continuation?
    private var isStreaming: Bool = false
    
    func startTracking() throws(MotionServiceError) -> AsyncThrowingStream<CMPedometerData, Error> {
        if isStreaming {
            throw MotionServiceError.alreadyStreaming
        }
        try ensureMotionAuthorized()
        try ensureCapabilitiesAvailable()
        
        // 매번 새로운 시작 시점(Date())으로 업데이트 시작
        let start = Date()
        return makeStreaming(start: start)
    }
    
    func stopTracking() {
        continuation?.finish()
    }
    
    // MARK: - Private Helpers
    private func ensureMotionAuthorized() throws(MotionServiceError) {
        switch CMPedometer.authorizationStatus() {
        case .denied, .restricted:
            throw MotionServiceError.notAuthorized
        case .authorized, .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    private func ensureCapabilitiesAvailable() throws(MotionServiceError) {
        let distance = CMPedometer.isDistanceAvailable()
        let pace = CMPedometer.isPaceAvailable()
        let steps = CMPedometer.isStepCountingAvailable()
        
        if !(distance || pace || steps) {
            throw MotionServiceError.unavailable
        }
    }
    
    /// 실제 AsyncThrowingStream 구성 및 pedometer 업데이트 시작
    private func makeStreaming(start: Date) -> AsyncThrowingStream<CMPedometerData, Error> {
        let stream = AsyncThrowingStream<CMPedometerData, Error> { [weak self] continuation in
            guard let self else { return }
            self.continuation = continuation
            isStreaming = true
            
            // Background Thread에서 실행
            pedometer.startUpdates(from: start) { [weak self] data, error in
                guard let self else { return }
                
                if let error {
                    continuation.finish(throwing: MotionServiceError.runtimeError(error))
                    return
                }
                
                if let data {
                    continuation.yield(data)
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                self?.cleanupStreaming()
            }
        }
        return stream
    }
    
    private func cleanupStreaming() {
        pedometer.stopUpdates()
        continuation = nil
        isStreaming = false
    }
    
    deinit {
        stopTracking()
    }
}

