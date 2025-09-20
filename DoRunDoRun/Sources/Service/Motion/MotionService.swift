//
//  MotionService.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/14/25.
//

import Foundation
import CoreMotion

final class MotionService: MotionServiceProtocol {
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
        
        let stream = AsyncThrowingStream<CMPedometerData, Error> { [weak self] continuation in
            guard let self else { return }
            self.continuation = continuation
            isStreaming = true
            
            // Background Thread에서 실행
            pedometer.startUpdates(from: start) { [weak self] data, error in
                guard self != nil else { return }
                if let error {
                    continuation.finish(throwing: MotionServiceError.runtimeError(error))
                    return
                }
                if let data {
                    _ = continuation.yield(data)
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                self?.cleanupStreaming()
            }
        }
        
        return stream
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
    
    /// pedometer 중단 및 상태 초기화
    private func cleanupStreaming() {
        pedometer.stopUpdates()
        continuation = nil
        isStreaming = false
    }
    
    deinit {
        stopTracking()
    }
}
