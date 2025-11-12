//
//  RunningSessionRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

/// 서버 기반 러닝 세션 관리 Repository 구현체
final class RunningSessionRepositoryImpl: RunningSessionRepository {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func createSession() async throws -> Int {
        let response = try await apiClient.request(
            RunningAPI.start,
            responseType: RunningStartResponseDTO.self
        )
        return response.data.sessionId
    }
    
    func saveSegments(
        sessionId: Int,
        points: [RunningPoint],
        metrics: RunningMetrics,
        isStopped: Bool
    ) async throws -> (segmentId: Int, savedCount: Int) {
        // RunningPoint -> SegmentDTO 변환
        let segments = points.map { point in
            SegmentDTO(
                from: point,
                distance: metrics.totalDistanceMeters,
                pace: metrics.currentPaceSecPerKm,
                cadence: metrics.currentCadenceSpm
            )
        }
        
        let request = RunningSegmentRequestDTO(
            segments: segments,
            isStopped: isStopped
        )
        
        let response = try await apiClient.request(
            RunningAPI.saveSegments(sessionId: sessionId, request: request),
            responseType: RunningSegmentResponseDTO.self
        )
        
        return (
            segmentId: response.data.segmentId,
            savedCount: response.data.savedCount
        )
    }
    
    func completeSession(
        sessionId: Int,
        detail: RunningDetail,
        mapImage: Data?
    ) async throws -> String? {
        let requestData = RunningCompleteRequestDTO(from: detail)

        let response = try await apiClient.request(
            RunningAPI.complete(sessionId: sessionId, data: requestData, mapImage: mapImage),
            responseType: RunningCompleteResponseDTO.self
        )

        return response.data.mapImage
    }
    
    func fetchSessions(
        isSelfied: Bool?,
        startDateTime: Date?,
        endDateTime: Date?
    ) async throws -> [RunningSessionSummary] {
        // Date를 ISO8601 문자열로 변환
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let startDateTimeString = startDateTime.map { formatter.string(from: $0) }
        let endDateTimeString = endDateTime.map { formatter.string(from: $0) }
        
        let response = try await apiClient.request(
            RunningAPI.sessions(
                isSelfied: isSelfied,
                startDateTime: startDateTimeString,
                endDateTime: endDateTimeString
            ),
            responseType: RunningSessionListResponseDTO.self
        )
        
        return response.data.map { $0.toDomain() }
    }
    
    func fetchSessionDetail(sessionId: Int) async throws -> RunningDetail {
        let response = try await apiClient.request(
            RunningAPI.sessionDetail(sessionId: sessionId),
            responseType: RunningSessionDetailResponseDTO.self
        )
        
        return response.data.toDomain()
    }
}
