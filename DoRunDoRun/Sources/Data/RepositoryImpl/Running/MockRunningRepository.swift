//
//  MockRunningRepository.swift
//
//
//  Created by zaehorang on 9/26/25.
//


import Foundation
import CoreLocation
import CoreMotion

/// 실시간 목 데이터 스트리머 (초당 1샘플)
actor MockRunningRepository: RunningRepositoryProtocol {

    // MARK: - 시작 좌표 (성수 엘리스랩 인근)
    private let startLat: Double = 37.5465029
    private let startLon: Double = 127.065263

    // MARK: - 상태
    private enum State { case idle, running, paused, stopped }
    private var state: State = .idle

    private var continuation: AsyncThrowingStream<RunningSnapshot, Error>.Continuation?
    private var tickerTask: Task<Void, Never>?

    private var startAt: Date?
    private var pausedAt: Date?
    private var totalPausedSec: TimeInterval = 0

    private var currentLat: Double = 0
    private var currentLon: Double = 0
    private var lastLocationTs: Date?
    private var lastLocation: CLLocation?
    private var totalDistanceMeters: Double = 0

    // 프로파일(기본 케이던스)
    private var baseCadenceSpm: Double = 170           // steps/min

    // MARK: - API
    func startRun() async throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        guard state == .idle || state == .stopped else {
            throw RunningError.alreadyRunning
        }

        reset()
        state = .running
        startAt = Date()

        // 초기 위치
        currentLat = startLat
        currentLon = startLon
        lastLocationTs = Date()
        lastLocation = nil

        let (stream, cont) = AsyncThrowingStream<RunningSnapshot, Error>.makeStream()
        continuation = cont

        // 소비 측에서 스트림을 끊으면 정리
        cont.onTermination = { [weak self] _ in
            Task { [weak self] in
                await self?.handleTermination()
            }
        }

        startTicker()
        return stream
    }

    func pause() async {
        guard state == .running else { return }
        state = .paused
        pausedAt = Date()
        stopTicker()
    }

    func resume() async throws {
        guard state == .paused, let pausedAt else { return }
        state = .running
        totalPausedSec += Date().timeIntervalSince(pausedAt)
        self.pausedAt = nil
        startTicker()
    }

    func stopRun() async {
        guard state == .running || state == .paused else { return }
        state = .stopped
        stopTicker()
        finishStream()
        reset()
    }

    // MARK: - Ticker
    private func startTicker() {
        tickerTask?.cancel()
        tickerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.tickOnce()
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec
            }
        }
    }

    private func stopTicker() {
        tickerTask?.cancel()
        tickerTask = nil
    }

    private func handleTermination() async {
        stopTicker()
        finishStream()
        state = .stopped
    }

    private func tickOnce() async {
        let dt: TimeInterval = 1.0
        advance(by: dt)

        // 새로운 위치 샘플 생성
        let now = Date()
        let newLoc = CLLocation(latitude: currentLat, longitude: currentLon)

        // 이전 위치가 있으면 CoreLocation으로 거리 누적
        if let prev = lastLocation {
            totalDistanceMeters += newLoc.distance(from: prev)
        }
        lastLocation = newLoc
        lastLocationTs = now

        yieldSnapshot()
    }

    // MARK: - 모의 이동/누적
    private func advance(by dt: TimeInterval) {
        guard state == .running else { return }

        // 좌표 기반으로만 약간 이동 (거리 계산은 CLLocation.distance가 담당)
        let eastStepDeg  = 2.7e-05   // 위도 37.5도 근처에서 대략 몇 미터 수준 (정확 거리는 CoreLocation이 계산)
        let northStepDeg = Double.random(in: -6e-06...6e-06)
        currentLat += northStepDeg
        currentLon += eastStepDeg + Double.random(in: -3e-06...3e-06)
        lastLocationTs = Date()

        // 케이던스 약한 변동
        let t = Date().timeIntervalSince(startAt ?? Date())
        baseCadenceSpm = 170 + sin(t / 6.0) * 6.0
    }

    // MARK: - Snapshot
    private func yieldSnapshot() {
        guard state == .running else { return }

        let elapsedSec = elapsedNow()
        let km = totalDistanceMeters / 1000.0
        let avgPace: Double = km > 0 ? (elapsedSec / km) : 0

        let metrics = RunningMetrics(
            totalDistanceMeters: totalDistanceMeters,
            elapsed: .seconds(elapsedSec),
            avgPaceSecPerKm: avgPace,
            cadenceSpm: baseCadenceSpm
        )

        let point: RunningPoint? = lastLocation.map {
            RunningPoint(
                timestamp: $0.timestamp,
                coordinate: RunningCoordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                altitude: Double.random(in: 20...40),
                speedMps: Double.random(in: 1...5)
            )
        }

        continuation?.yield(
            RunningSnapshot(
                timestamp: point?.timestamp ?? Date(),
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
        lastLocationTs = nil
        lastLocation = nil
        totalDistanceMeters = 0
        baseCadenceSpm = 170
    }
}
