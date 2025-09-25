//
//  RunningRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/25/25.
//

import CoreLocation
import CoreMotion

/// 센서 스트림을 합쳐 세션 상태를 관리하고 도메인 스냅샷을 생성
final class RunningRepositoryImpl: RunningRepositoryProtocol {
    
    // MARK: Dependencies
    private let locationService: LocationServiceProtocol
    private let motionService: MotionServiceProtocol
    
    // MARK: Session State
    private enum State { case idle, running, paused, stopped }
    private var state: State = .idle
    
    private var continuation: AsyncThrowingStream<RunningSnapshot, Error>.Continuation?
    private var consumerTasks: [Task<Void, Never>] = []
    
    // 누적 변수
    private var startAt: Date?
    private var pausedAt: Date?
    private var totalPausedSec: TimeInterval = 0
    
    private var lastLocation: CLLocation?
    private var lastPedometer: CMPedometerData?
    private var totalDistanceMeters: Double = 0
    private var latestCadenceSpm: Double = 0
    
    private var currentSnapshotTimestamp: Date {
        lastLocation?.timestamp ?? lastPedometer?.startDate ?? Date()
    }
    
    // MARK: Init
    init(
        locationService: LocationServiceProtocol,
        motionService: MotionServiceProtocol
    ) {
        self.locationService = locationService
        self.motionService = motionService
    }
    
    // MARK: API
    func startRun() throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        guard state == .idle || state == .stopped else {
            throw RunningError.alreadyRunning
        }
        
        resetAccumulators()
        state = .running
        startAt = Date()
        
        let (stream, cont) = AsyncThrowingStream<RunningSnapshot, Error>.makeStream()
        continuation = cont
        
        try startAndSubscribeServices()
        return stream
    }
    
    func pause() {
        guard state == .running else { return }
        
        state = .paused
        pausedAt = Date()
        
        stopServices()
        cancelConsumers()
        
        // 정지 구간 이동거리 제외: 재개 시 첫 위치를 기준점으로 사용
        lastLocation = nil
    }
    
    func resume() throws {
        guard state == .paused, let pausedAt else { return }
        
        state = .running
        totalPausedSec += Date().timeIntervalSince(pausedAt)
        self.pausedAt = nil
        
        try startAndSubscribeServices()
    }
    
    func stopRun() {
        guard state == .running || state == .paused else { return }
        state = .stopped
        
        stopServices()
        cancelConsumers()
        
        continuation?.finish()
        continuation = nil
        
        resetAccumulators()
    }
    
    // MARK: Service subscription
    private func startAndSubscribeServices() throws {
        // 네 서비스 프로토콜 시그니처를 그대로 사용 (스트림 Error 타입은 Error)
        let locationStream = try locationService.startTracking()
        let motionStream = try motionService.startTracking()
        
        // 위치 스트림 소비
        let t1 = Task { [weak self] in
            guard let self else { return }
            do {
                for try await loc in locationStream {
                    self.consumeLocation(loc)
                }
            } catch {
                self.finishWith(error: self.mapError(error, origin: .location))
            }
        }
        
        // 모션 스트림 소비
        let t2 = Task { [weak self] in
            guard let self else { return }
            do {
                for try await ped in motionStream {
                    self.consumePedometer(ped)
                }
            } catch {
                self.finishWith(error: self.mapError(error, origin: .motion))
            }
        }
        
        consumerTasks = [t1, t2]
    }
    
    private func cancelConsumers() {
        consumerTasks.forEach { $0.cancel() }
        consumerTasks.removeAll()
    }
    
    private func stopServices() {
        locationService.stopTracking()
        motionService.stopTracking()
    }
    
    // MARK: Reducers
    private func consumeLocation(_ location: CLLocation) {
        guard state == .running else { return }
        
        if let prev = lastLocation {
            totalDistanceMeters += location.distance(from: prev)
        }
        lastLocation = location
        
        yieldSnapshot()
    }
    
    private func consumePedometer(_ ped: CMPedometerData) {
        guard state == .running else { return }
        
        // steps/sec → steps/min
        if let stepsPerSec = ped.currentCadence?.doubleValue {
            latestCadenceSpm = stepsPerSec * 60.0
        }
        lastPedometer = ped
        
        yieldSnapshot()
    }
    
    private func yieldSnapshot() {
        let elapsedSec = elapsedNow()
        let km = totalDistanceMeters / 1000.0
        let avgPace: Double = km > 0 ? (elapsedSec / km) : 0
        
        let metrics = RunningMetrics(
            totalDistanceMeters: totalDistanceMeters,
            elapsed: .seconds(elapsedSec),
            avgPaceSecPerKm: avgPace,
            cadenceSpm: latestCadenceSpm
        )
        
        let point = lastLocation.map { $0.toRunningPoint() }
        
        continuation?.yield(
            RunningSnapshot(
                timestamp: currentSnapshotTimestamp,
                lastPoint: point,
                metrics: metrics
            )
        )
    }
    
    // MARK: Helpers
    private func elapsedNow() -> TimeInterval {
        guard let startAt else { return 0 }
        
        let now = Date().timeIntervalSince(startAt)
        return max(0, now - totalPausedSec)
    }
    
    private func resetAccumulators() {
        startAt = nil
        pausedAt = nil
        totalPausedSec = 0
        lastLocation = nil
        totalDistanceMeters = 0
        latestCadenceSpm = 0
    }
}

extension RunningRepositoryImpl {
    // 에러 매핑 (서비스가 Error로 던지므로, 의미 있는 도메인 에러로 변환)
    private enum ErrorOrigin { case location, motion }
    
    private func mapError(_ error: Error, origin: ErrorOrigin) -> RunningError {
        if let le = error as? LocationServiceError {
            switch le {
            case .notAuthorized:      return .locationNotAuthorized
            case .alreadyStreaming:   return .runtime(le)
            case .runtimeError(let e):return .runtime(e)
            }
        }
        if let me = error as? MotionServiceError {
            switch me {
            case .notAuthorized:      return .motionNotAuthorized
            case .unavailable:        return .sensorUnavailable
            case .alreadyStreaming:   return .runtime(me)
            case .runtimeError(let e):return .runtime(e)
            }
        }
        return .runtime(error)
    }
    
    private func finishWith(error: RunningError) {
        continuation?.finish(throwing: error)
        continuation = nil
        cancelConsumers()
        state = .stopped
    }
}
