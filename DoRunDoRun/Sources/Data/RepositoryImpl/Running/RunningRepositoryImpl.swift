//
//  RunningRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/25/25.
//

import CoreLocation
import CoreMotion

actor RunningRepositoryImpl: RunningRepository {
    
    // MARK: Dependencies
    private let runningService: RunningService
    
    // MARK: Session State
    private enum State { case idle, running, paused, stopped }
    private var state: State = .idle
    
    private var continuation: AsyncThrowingStream<RunningSnapshot, Error>.Continuation?
    private var consumerTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?   // 매초 틱
    
    // 누적 변수
    private var startAt: Date?
    private var pausedAt: Date?
    private var totalPausedSec: TimeInterval = 0
    
    private var totalDistanceMeters: Double = 0
    private var latestCadenceSpm: Double = 0
    
    private var lastLocation: CLLocation?
    private var lastPedometer: CMPedometerData?
    
    // MARK: Init
    init(runningService: RunningService = RunningServiceImpl()) {
        self.runningService = runningService
    }
    
    // MARK: API
    func startRun() async throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        guard state == .idle || state == .stopped else {
            throw RunningError.alreadyRunning
        }
        
        resetAccumulators()
        
        state = .running
        startAt = Date()
        
        let (stream, cont) = AsyncThrowingStream<RunningSnapshot, Error>.makeStream()
        continuation = cont
        
        try subscribeRunningService()
        startTimerTick()
        
        return stream
    }
    
    func pause() async {
        guard state == .running else { return }
        state = .paused
        pausedAt = Date()
        
        // 센서 스트림 자체를 중단하여 pause 구간 데이터가 생성/버퍼되지 않도록
        await runningService.stop()
        
        // 소비/타이머 중단
        cancelConsumer()
        cancelTimer()
        
        // 정지 구간 이동거리 제외: 재개 시 첫 위치/보행 데이터를 새로운 기준으로 사용
        lastLocation = nil
        lastPedometer = nil
    }
    
    func resume() async throws {
        guard state == .paused, let pausedAt else { return }
        state = .running
        totalPausedSec += Date().timeIntervalSince(pausedAt)
        self.pausedAt = nil
        
        // 서비스는 start/stop만 제공하므로, 재개 시 새 스트림을 start()로 받아 재구독한다.
        try subscribeRunningService()
        startTimerTick()
    }
    
    func stopRun() async {
        guard state == .running || state == .paused else { return }
        state = .stopped
        
        await runningService.stop()
        cancelConsumer()
        cancelTimer()
        
        continuation?.finish()
        continuation = nil
        
        resetAccumulators()
    }
    
    // MARK: Service subscription
    private func subscribeRunningService() throws {
        let eventStream = try runningService.start()
        
        consumerTask?.cancel()
        consumerTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await event in eventStream {
                    if Task.isCancelled { break }
                    await self.consume(event)
                }
            } catch is CancellationError {
                // 정상 취소
            } catch {
                await self.finishWith(error: .runtime(error))
            }
        }
    }
    
    private func cancelConsumer() {
        consumerTask?.cancel()
        consumerTask = nil
    }
    
    // MARK: Timer tick
    private func startTimerTick() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }
            // 1초 주기 틱
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await self.timerTick()
            }
        }
    }
    
    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
    
    private func timerTick() {
        // running 상태에서만 주기적으로 스냅샷 발행
        guard state == .running else { return }
        yieldSnapshot(timestamp: Date())
    }
    
    // MARK: Reducers
    private func consume(_ event: RunningSensorEvent) {
        guard state == .running else { return }
        
        switch event {
        case .location(let location):
            if let prev = lastLocation {
                totalDistanceMeters += location.distance(from: prev)
            }
            lastLocation = location
            yieldSnapshot(timestamp: location.timestamp)
            
        case .pedometer(let ped):
            if let stepsPerSec = ped.currentCadence?.doubleValue {
                latestCadenceSpm = stepsPerSec * 60.0
            }
            lastPedometer = ped
            yieldSnapshot(timestamp: ped.endDate)
        }
    }
    
    private func yieldSnapshot(timestamp: Date) {
        let elapsedSec = elapsedNow()
        let km = totalDistanceMeters / 1000.0
        let avgPace: Double = km > 0 ? (elapsedSec / km) : 0
        
        let metrics = RunningMetrics(
            totalDistanceMeters: totalDistanceMeters,
            elapsed: .seconds(elapsedSec),
            avgPaceSecPerKm: avgPace,
            cadenceSpm: latestCadenceSpm
        )
        
        let point = lastLocation.map { $0.toDomain() }
        
        continuation?.yield(
            RunningSnapshot(
                timestamp: timestamp,
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
        lastPedometer = nil
    }
}

private extension RunningRepositoryImpl {
    private func finishWith(error: RunningError) async {
        continuation?.finish(throwing: error)
        continuation = nil
        cancelConsumer()
        cancelTimer()
        state = .stopped
    }
}
