//
//  RunningUseCase.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/22/25.
//

protocol RunningUseCaseProtocol {
    /// 서버 세션 생성 (Ready 단계에서 호출)
    func createSession() async throws -> Int

    /// 로컬 추적 시작 및 스냅샷 스트림 반환 (Active 단계에서 호출)
    func startTracking() async throws -> AsyncThrowingStream<RunningSnapshot, Error>

    func pause() async
    func resume() async throws
    func stop() async -> (detail: RunningDetail, sessionId: Int?)
}

final class RunningUseCase: RunningUseCaseProtocol {
    private let trackingRepository: RunningTrackingRepository
    private let sessionRepository: RunningSessionRepository

    // 서버 세션 관리
    private var sessionId: Int?
    private var segmentSaveTask: Task<Void, Never>?
    private var accumulatedPoints: [RunningPoint] = []
    private var lastMetrics: RunningMetrics?

    init(
        trackingRepository: RunningTrackingRepository,
        sessionRepository: RunningSessionRepository
    ) {
        self.trackingRepository = trackingRepository
        self.sessionRepository = sessionRepository
    }

    func createSession() async throws -> Int {
        // 서버 세션 생성하고 ID 반환
        let id = try await sessionRepository.createSession()
        sessionId = id
        print("✅ Session created: \(id)")
        return id
    }

    func startTracking() async throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        // 1. 로컬 추적 시작
        let stream = try await trackingRepository.startTracking()

        // 2. 5분마다 세그먼트 자동 저장 시작
        startPeriodicSegmentSave()

        // 3. 스냅샷을 소비하며 포인트 누적
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await snapshot in stream {
                        // 포인트 누적 (서버 전송용)
                        if let point = snapshot.lastPoint {
                            accumulatedPoints.append(point)
                        }
                        lastMetrics = snapshot.metrics

                        continuation.yield(snapshot)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func pause() async {
        // 1. 로컬 추적 일시정지
        await trackingRepository.pauseTracking()

        // 2. 세그먼트 저장 중단
        segmentSaveTask?.cancel()

        // 3. 현재까지 누적된 데이터 서버 전송 (isStopped: false)
        await saveCurrentSegment(isStopped: false)
    }

    func resume() async throws {
        // 1. 로컬 추적 재개
        try await trackingRepository.resumeTracking()

        // 2. 세그먼트 자동 저장 재시작
        startPeriodicSegmentSave()
    }

    func stop() async -> (detail: RunningDetail, sessionId: Int?) {
        // 1. 세그먼트 저장 중단
        segmentSaveTask?.cancel()

        // 2. 로컬 추적 종료
        let detail = await trackingRepository.stopTracking()

        // 3. 최종 세그먼트 저장 (isStopped: true)
        await saveCurrentSegment(isStopped: true)

        // 4. sessionId 저장 (resetSessionState 전에)
        let currentSessionId = self.sessionId

        // 5. 상태 초기화 (서버 완료는 RunningDetailFeature에서 처리)
        resetSessionState()

        return (detail, currentSessionId)
    }

    // MARK: - Private Helpers

    /// 5분마다 세그먼트 자동 저장
    private func startPeriodicSegmentSave() {
        segmentSaveTask?.cancel()
        segmentSaveTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(300))  // 5분
                await self?.saveCurrentSegment(isStopped: false)
            }
        }
    }

    /// 현재 누적된 세그먼트를 서버에 저장
    private func saveCurrentSegment(isStopped: Bool) async {
        guard let sessionId,
              !accumulatedPoints.isEmpty,
              let metrics = lastMetrics else {
            return
        }

        do {
            let (segmentId, savedCount) = try await sessionRepository.saveSegments(
                sessionId: sessionId,
                points: accumulatedPoints,
                metrics: metrics,
                isStopped: isStopped
            )
            print("✅ Saved segment: \(segmentId), count: \(savedCount)")

            // 저장 완료 후 누적 데이터 초기화
            accumulatedPoints.removeAll()
        } catch {
            print("⚠️ Failed to save segment: \(error)")
        }
    }

    /// 세션 상태 초기화
    private func resetSessionState() {
        sessionId = nil
        accumulatedPoints.removeAll()
        lastMetrics = nil
        segmentSaveTask = nil
    }
}
