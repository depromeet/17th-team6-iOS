//
//  RunningTrackingRepositoryMock.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation
import CoreLocation

/// 센서 없이 주기적으로 변하는 러닝 스냅샷을 방출하는 Mock 저장소
actor RunningTrackingRepositoryMock: RunningTrackingRepository {

    // MARK: - 시작 좌표 (성수 일대)
    private let startLat: Double = 37.5465029
    private let startLon: Double = 127.065263

    // MARK: - 상태
    private enum State { case idle, running, paused, stopped }
    private var state: State = .idle

    private var continuation: AsyncThrowingStream<RunningSnapshot, Error>.Continuation?
    private var tickerTask: Task<Void, Never>?

    // 세션 시간 관리
    private var startAt: Date?
    private var pausedAt: Date?
    private var totalPausedSec: TimeInterval = 0

    // 이동/누적
    private var currentLat: Double = 0
    private var currentLon: Double = 0
    private var lastLocation: CLLocation?
    private var totalDistanceMeters: Double = 0

    // 모의 이동 파라미터
    private var headingDeg: Double = 90.0         // 동쪽(90도) 시작
    private var speedMps: Double = 3.2            // 약 5:13/km 정도
    private var cadenceSpm: Double = 172.0

    // 수집 데이터 저장
    private var coordinates: [RunningPoint] = []
    private var cadenceSamples: [Double] = []
    private var fastestSpeed: Double = 0
    private var coordinateAtFastestSpeed: RunningPoint?

    // MARK: - API
    func startTracking() async throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        guard state == .idle || state == .stopped else {
            throw RunningError.alreadyRunning
        }

        reset()
        state = .running
        startAt = Date()

        // 시작 좌표
        currentLat = startLat
        currentLon = startLon
        lastLocation = nil

        let (stream, cont) = AsyncThrowingStream<RunningSnapshot, Error>.makeStream()
        continuation = cont

        cont.onTermination = { [weak self] _ in
            Task { [weak self] in
                await self?.cleanupOnTermination()
            }
        }

        startTicker()
        return stream
    }

    func pauseTracking() async {
        guard state == .running else { return }
        state = .paused
        pausedAt = Date()
        stopTicker()

        // 일시정지 구간의 이동거리 제외를 위해 기준 리셋
        lastLocation = nil
    }

    func resumeTracking() async throws {
        guard state == .paused, let pausedAt else { return }
        state = .running
        totalPausedSec += Date().timeIntervalSince(pausedAt)
        self.pausedAt = nil

        // 재개 시에도 정지 구간 이동거리 제외를 위해 기준 리셋
        lastLocation = nil

        startTicker()
    }

    func stopTracking(sessionId: Int?) async -> RunningDetail {
        guard state == .running || state == .paused else {
            return RunningDetail(
                sessionId: sessionId,
                startedAt: Date(),
                finishedAt: Date().addingTimeInterval(3600),
                totalDistanceMeters: 3210.5,
                elapsed: .seconds(900),
                avgPaceSecPerKm: 280.0,
                avgCadenceSpm: 175.0,
                maxCadenceSpm: 186.0,
                fastestPaceSecPerKm: 265.0,
                coordinateAtmaxPace: RunningPoint(
                    timestamp: Date(),
                    coordinate: RunningCoordinate(latitude: 37.5465, longitude: 127.0652),
                    altitude: 25.0,
                    speedMps: 3.8
                ),
                coordinates: [],
                mapImageData: nil,
                mapImageURL: nil,
                feed: nil
            )
        }

        // 실제 수집한 데이터 기반으로 통계 계산
        let elapsedSec = elapsedNow()
        let km = totalDistanceMeters / 1000.0
        let avgPaceSecPerKm: Double = km > 0 ? (elapsedSec / km) : 0

        // 평균 케이던스 계산
        let avgCadence = cadenceSamples.isEmpty ? 0 : cadenceSamples.reduce(0, +) / Double(cadenceSamples.count)
        // 최대 케이던스
        let maxCadence = cadenceSamples.max() ?? 0

        // 가장 빠른 페이스 (가장 빠른 속도 = 가장 작은 페이스 값)
        let fastestPaceSecPerKm: Double = fastestSpeed > 0 ? (1000.0 / fastestSpeed) : 0

        // 시작/종료 시각
        let startedAt = self.startAt ?? Date()
        let finishedAt = Date()

        // 가장 빠른 속도 지점 (없으면 첫 번째 좌표 사용)
        let fastestCoordinate = coordinateAtFastestSpeed ?? coordinates.first ?? RunningPoint(
            timestamp: Date(),
            coordinate: RunningCoordinate(latitude: startLat, longitude: startLon),
            altitude: 25.0,
            speedMps: 0
        )

        let detail = RunningDetail(
            sessionId: sessionId,
            startedAt: startedAt,
            finishedAt: finishedAt,
            totalDistanceMeters: totalDistanceMeters,
            elapsed: .seconds(elapsedSec),
            avgPaceSecPerKm: avgPaceSecPerKm,
            avgCadenceSpm: avgCadence,
            maxCadenceSpm: maxCadence,
            fastestPaceSecPerKm: fastestPaceSecPerKm,
            coordinateAtmaxPace: fastestCoordinate,
            coordinates: coordinates,
            mapImageData: nil,
            mapImageURL: nil,
            feed: nil
        )

        state = .stopped
        stopTicker()
        finishStream()
        reset()

        return detail
    }

    // MARK: - Ticker
    private func startTicker() {
        tickerTask?.cancel()
        tickerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.tickOnce()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func stopTicker() {
        tickerTask?.cancel()
        tickerTask = nil
    }

    private func cleanupOnTermination() async {
        stopTicker()
        finishStream()
        state = .stopped
    }

    private func tickOnce() async {
        guard state == .running else { return }

        // 1) 이동 파라미터에 약간의 노이즈 추가
        //   - 방향은 -2...+2도 정도로 흔들림
        //   - 속도는 ±0.4 m/s 범위에서 변화 (페이스 색상 변화를 위해 증폭)
        headingDeg += Double.random(in: -2...2)
        headingDeg.formTruncatingRemainder(dividingBy: 360)

        let speedNoise = Double.random(in: -0.4...0.4)
        // 속도 범위: 2.0-5.0 m/s (8:20/km - 3:20/km) → PaceColorMapper 범위에 최적화
        speedMps = max(2.0, min(5.0, speedMps + speedNoise))

        // 케이던스는 속도와 느슨하게 연동 (대략 160~185 spm 사이)
        let cadenceBase = 160.0 + (speedMps - 2.0) * 10.0
        cadenceSpm = max(160.0, min(185.0, cadenceBase + Double.random(in: -3...3)))

        // 2) 속도/방향으로 1초 이동
        let meters = speedMps * 1.0
        moveBy(meters: meters, headingDeg: headingDeg)

        // 3) 거리 누적
        let newLoc = CLLocation(latitude: currentLat, longitude: currentLon)
        if let prev = lastLocation {
            totalDistanceMeters += newLoc.distance(from: prev)
        }
        lastLocation = newLoc

        // 4) 스냅샷 방출
        yieldSnapshot()
    }

    // MARK: - 이동 계산
    private func moveBy(meters: Double, headingDeg: Double) {
        // 지구상에서 위경도 오프셋 계산 (간단한 근사)
        // 위도 1m ≈ 1 / 111_111 deg
        // 경도 1m ≈ 1 / (111_111 * cos(lat)) deg
        let rad = headingDeg * .pi / 180.0
        let dx = meters * cos(rad)   // 동서
        let dy = meters * sin(rad)   // 남북

        let latMetersPerDeg = 111_111.0
        let lonMetersPerDeg = 111_111.0 * cos(currentLat * .pi / 180.0)

        let dLat = dy / latMetersPerDeg
        let dLon = dx / lonMetersPerDeg

        currentLat += dLat
        currentLon += dLon
    }

    // MARK: - Snapshot
    private func yieldSnapshot() {
        let elapsedSec = elapsedNow()
        let km = totalDistanceMeters / 1000.0
        let avgPaceSecPerKm: Double = km > 0 ? (elapsedSec / km) : 0

        // 순간 페이스 계산: speedMps(m/s)를 페이스(초/km)로 변환
        let currentPaceSecPerKm: Double = speedMps > 0 ? (1000.0 / speedMps) : 0

        let metrics = RunningMetrics(
            totalDistanceMeters: totalDistanceMeters,
            elapsed: .seconds(elapsedSec),
            currentPaceSecPerKm: currentPaceSecPerKm,
            currentCadenceSpm: cadenceSpm
        )

        let point: RunningPoint = RunningPoint(
            timestamp: Date(),
            coordinate: RunningCoordinate(latitude: currentLat, longitude: currentLon),
            altitude: Double.random(in: 15...35),
            speedMps: speedMps
        )

        // 데이터 저장
        coordinates.append(point)
        cadenceSamples.append(cadenceSpm)

        // 가장 빠른 속도 추적
        if speedMps > fastestSpeed {
            fastestSpeed = speedMps
            coordinateAtFastestSpeed = point
        }

        continuation?.yield(
            RunningSnapshot(
                timestamp: point.timestamp,
                lastPoint: point,
                metrics: metrics
            )
        )
    }

    // MARK: - Helpers
    private func elapsedNow() -> TimeInterval {
        guard let s = startAt else { return 0 }
        let now = Date().timeIntervalSince(s)
        return max(0, now - totalPausedSec)
    }

    private func finishStream() {
        continuation?.finish()
        continuation = nil
    }

    private func reset() {
        startAt = nil
        pausedAt = nil
        totalPausedSec = 0

        currentLat = startLat
        currentLon = startLon
        lastLocation = nil
        totalDistanceMeters = 0

        headingDeg = 90.0
        speedMps = 3.2
        cadenceSpm = 172.0

        coordinates = []
        cadenceSamples = []
        fastestSpeed = 0
        coordinateAtFastestSpeed = nil
    }
}
