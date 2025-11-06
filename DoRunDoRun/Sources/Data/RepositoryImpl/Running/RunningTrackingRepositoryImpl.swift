//
//  RunningTrackingRepositoryImpl.swift
//  DoRunDoRun
//
//

import CoreLocation
import CoreMotion

actor RunningTrackingRepositoryImpl: RunningTrackingRepository {

    // MARK: Dependencies
    private let runningService: RunningService

    // MARK: Session State
    private enum State { case idle, running, paused, stopped }
    private var state: State = .idle

    private var continuation: AsyncThrowingStream<RunningSnapshot, Error>.Continuation?
    private var consumerTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?   // 매초 틱

    // 누적 변수
    private var startedAt: Date?
    private var pausedAt: Date?

    private var totalPausedSec: TimeInterval = 0
    private var totalSec: TimeInterval = 0

    private var totalDistanceMeters: Double = 0
    private var latestCadenceSpm: Double = 0
    private var latestCurrentPaceSecPerKm: Double = 0

    // 전체 경로 좌표 정보
    private var points: [RunningCoordinate] = []

    // 누적 걸음수 (일시정지 구간 제외, pedometer 이벤트 델타 기반)
    private var totalSteps: Int = 0

    // 최대값 저장
    private var maxCadenceSpm: Double = 0
    private var fastestPaceSecPerKm: Double = .infinity
    private var coordinateAtMaxPace: RunningPoint?

    private var lastLocation: CLLocation?
    private var lastPedometer: CMPedometerData?

    // MARK: Init
    init(runningService: RunningService = RunningServiceImpl()) {
        self.runningService = runningService
    }

    // MARK: API
    func startTracking() async throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        guard state == .idle || state == .stopped else {
            throw RunningError.alreadyRunning
        }

        resetAccumulators()

        state = .running
        startedAt = Date()

        let (stream, cont) = AsyncThrowingStream<RunningSnapshot, Error>.makeStream()
        continuation = cont

        try subscribeRunningService()
        startTimerTick()

        return stream
    }

    func pauseTracking() async {
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

    func resumeTracking() async throws {
        guard state == .paused, let pausedAt else { return }
        state = .running
        totalPausedSec += Date().timeIntervalSince(pausedAt)
        self.pausedAt = nil

        // 서비스는 start/stop만 제공하므로, 재개 시 새 스트림을 start()로 받아 재구독한다.
        try subscribeRunningService()
        startTimerTick()
    }

    func stopTracking() async -> RunningDetail {
        guard state == .running || state == .paused else {
            // 이미 중지 상태라면, 현재 누적 데이터를 기준으로 요약 반환
            let runningDetail = makeFinalRunningDetail()

            await runningService.stop()
            cancelConsumer()
            cancelTimer()
            continuation?.finish()
            continuation = nil
            resetAccumulators()
            state = .stopped

            return runningDetail
        }

        state = .stopped

        await runningService.stop()
        cancelConsumer()
        cancelTimer()

        continuation?.finish()
        continuation = nil

        let runningDetail = makeFinalRunningDetail()
        resetAccumulators()
        return runningDetail
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

            // GPS 속도로 즉시 페이스 계산
            if location.speed > 0 {
                latestCurrentPaceSecPerKm = 1000.0 / location.speed
            } else {
                // 정지 상태 또는 GPS 신호 없음
                latestCurrentPaceSecPerKm = 0
            }

            yieldSnapshot(timestamp: location.timestamp)

        case .pedometer(let ped):
            if let stepsPerSec = ped.currentCadence?.doubleValue {
                latestCadenceSpm = stepsPerSec * 60.0
            } else {
                // 멈춤 상태 또는 데이터 없음 → 0으로 명시
                latestCadenceSpm = 0
            }

            // 누적 걸음수: 직전 측정치와의 차이를 더함 (첫 샘플은 델타 계산 제외)
            if let prev = lastPedometer {
                let delta = ped.numberOfSteps.intValue - prev.numberOfSteps.intValue
                if delta > 0 { totalSteps += delta }
            }

            lastPedometer = ped
            updateMaxMetrics(location: lastLocation)
            yieldSnapshot(timestamp: ped.endDate)
        }
    }

    private func yieldSnapshot(timestamp: Date) {
        totalSec = elapsedNow()

        let metrics = RunningMetrics(
            totalDistanceMeters: totalDistanceMeters,
            elapsed: .seconds(totalSec),
            currentPaceSecPerKm: latestCurrentPaceSecPerKm,
            currentCadenceSpm: latestCadenceSpm
        )

        let point = lastLocation.map { $0.toDomain() }

        if let point { points.append(point.coordinate) }

        continuation?.yield(
            RunningSnapshot(
                timestamp: timestamp,
                lastPoint: point,
                metrics: metrics
            )
        )
    }

    // MARK: Helpers
    private func averagePaceSecPerKm(
        distanceMeters: Double,
        elapsedSec: TimeInterval
    ) -> Double {
        if distanceMeters < 1 { return 0 } // 1m 이상일 때만 계산

        let km = distanceMeters / 1000.0
        return elapsedSec / km
    }

    private func averageCadenceSpm(
        totalSteps: Int,
        elapsedSec: TimeInterval
    ) -> Double {
        let minutes = elapsedSec / 60.0
        return (minutes > 0) ? (Double(totalSteps) / minutes) : 0
    }

    private func makeFinalRunningDetail() -> RunningDetail {
        let finishedAt = pausedAt ?? Date()
        let avgCadence = averageCadenceSpm(totalSteps: totalSteps, elapsedSec: totalSec)
        let avgPace = averagePaceSecPerKm(distanceMeters: totalDistanceMeters, elapsedSec: totalSec)
        let coord = coordinateAtMaxPace
        ?? lastLocation?.toDomain()
        ?? RunningPoint(timestamp: .now, coordinate: .init(latitude: 0, longitude: 0), altitude: 0, speedMps: 0)

        return RunningDetail(
            startedAt: startedAt ?? Date(),
            finishedAt: finishedAt,
            totalDistanceMeters: totalDistanceMeters,
            elapsed: .seconds(totalSec),
            avgPaceSecPerKm: avgPace,
            avgCadenceSpm: avgCadence,
            maxCadenceSpm: maxCadenceSpm,
            fastestPaceSecPerKm: fastestPaceSecPerKm.isFinite ? fastestPaceSecPerKm : 0,
            coordinateAtmaxPace: coord,
            coordinates: points,
            mapImageData: nil,
            mapImageURL: nil,
            feed: nil
        )
    }

    private func elapsedNow() -> TimeInterval {
        guard let startedAt else { return 0 }
        let finishedAt = pausedAt ?? Date()
        let now = finishedAt.timeIntervalSince(startedAt)

        return max(0, now - totalPausedSec)
    }

    private func updateMaxMetrics(location: CLLocation?) {
        maxCadenceSpm = max(latestCadenceSpm, maxCadenceSpm)

        if latestCurrentPaceSecPerKm > 0, latestCurrentPaceSecPerKm < fastestPaceSecPerKm {
            fastestPaceSecPerKm = latestCurrentPaceSecPerKm
            if let loc = location {
                coordinateAtMaxPace = loc.toDomain()
            }
        }
    }

    private func resetAccumulators() {
        startedAt = nil
        pausedAt = nil
        totalPausedSec = 0
        lastLocation = nil
        totalDistanceMeters = 0
        latestCadenceSpm = 0
        latestCurrentPaceSecPerKm = 0
        maxCadenceSpm = 0
        fastestPaceSecPerKm = .infinity
        coordinateAtMaxPace = nil
        lastPedometer = nil
        totalSteps = 0
        totalSec = 0
    }
}

private extension RunningTrackingRepositoryImpl {
    private func finishWith(error: RunningError) async {
        continuation?.finish(throwing: error)
        continuation = nil
        cancelConsumer()
        cancelTimer()
        state = .stopped
    }
}
