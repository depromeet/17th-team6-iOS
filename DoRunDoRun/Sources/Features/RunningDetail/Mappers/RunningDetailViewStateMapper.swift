//
//  RunningDetailViewStateMapper.swift
//
//
//  Created by zaehorang on 10/31/25.
//


import Foundation

struct RunningDetailViewStateMapper {
    /// Domain → ViewState (Forward Mapping)
    static func map(from detail: RunningDetail) -> RunningDetailViewState {
        // FinishedAt → "2025.10.09 · 오전 10:11" 형식으로
        let finishedAtText = formatDate(detail.finishedAt)

        let distanceText = formatDistance(detail.totalDistanceMeters)

        // Duration → "1:52:06" 형식으로
        let elapsedText = formatDuration(detail.elapsed)

        // Pace → "7'30\"" 형식으로
        let paceText = formatPace(detail.avgPaceSecPerKm)

        // Cadence → "144 spm" 형식으로
        let cadenceText = "\(Int(detail.avgCadenceSpm)) spm"

        // 결과 화면에서는 전체 평균 페이스를 모든 좌표에 적용
        let points = detail.coordinates.map { toViewState($0, pace: detail.avgPaceSecPerKm) }

        return RunningDetailViewState(
            // 세션 정보
            sessionId: detail.sessionId,
            // Formatted strings
            finishedAtText: finishedAtText,
            totalDistanceText: distanceText,
            avgPaceText: paceText,
            durationText: elapsedText,
            cadenceText: cadenceText,
            // Domain 원본 값
            startedAt: detail.startedAt,
            finishedAt: detail.finishedAt,
            totalDistanceMeters: detail.totalDistanceMeters,
            elapsed: detail.elapsed,
            avgPaceSecPerKm: detail.avgPaceSecPerKm,
            avgCadenceSpm: detail.avgCadenceSpm,
            maxCadenceSpm: detail.maxCadenceSpm,
            fastestPaceSecPerKm: detail.fastestPaceSecPerKm,
            coordinateAtmaxPace: detail.coordinateAtmaxPace,
            // 지도
            points: points,
            coordinates: detail.coordinates,
            mapImageData: detail.mapImageData,
            mapImageURL: detail.mapImageURL,
            // 기타
            feed: detail.feed
        )
    }

    /// ViewState → Domain (Reverse Mapping)
    static func toDomain(from viewState: RunningDetailViewState) -> RunningDetail {
        return RunningDetail(
            sessionId: viewState.sessionId,
            startedAt: viewState.startedAt,
            finishedAt: viewState.finishedAt,
            totalDistanceMeters: viewState.totalDistanceMeters,
            elapsed: viewState.elapsed,
            avgPaceSecPerKm: viewState.avgPaceSecPerKm,
            avgCadenceSpm: viewState.avgCadenceSpm,
            maxCadenceSpm: viewState.maxCadenceSpm,
            fastestPaceSecPerKm: viewState.fastestPaceSecPerKm,
            coordinateAtmaxPace: viewState.coordinateAtmaxPace,
            coordinates: viewState.coordinates,
            mapImageData: viewState.mapImageData,
            mapImageURL: viewState.mapImageURL,
            feed: viewState.feed
        )
    }
    
    /// ViewState(RunningSessionSummary) → ViewState(RunningDetail)
    static func map(from summary: RunningSessionSummaryViewState) -> RunningDetailViewState {
        let distanceValue = Double(summary.distanceText
            .replacingOccurrences(of: "km", with: "")
            .trimmingCharacters(in: .whitespaces)) ?? 0.0

        return RunningDetailViewState(
            // MARK: - 세션 정보
            sessionId: summary.id,

            // MARK: - 표시용 텍스트
            finishedAtText: summary.timeText,
            totalDistanceText: summary.distanceText,
            avgPaceText: summary.paceText,
            durationText: summary.durationText,
            cadenceText: summary.spmText,

            // MARK: - 원본 데이터
            startedAt: summary.date,
            finishedAt: summary.date,
            totalDistanceMeters: distanceValue * 1000,
            elapsed: .seconds(0),
            avgPaceSecPerKm: 0,
            avgCadenceSpm: 0,
            maxCadenceSpm: 0,
            fastestPaceSecPerKm: 0,
            coordinateAtmaxPace: RunningPoint(
                timestamp: Date(),
                coordinate: RunningCoordinate(latitude: 0, longitude: 0),
                altitude: 0,
                speedMps: 0
            ),

            // MARK: - 지도 관련
            points: [],
            coordinates: [],
            mapImageData: nil,
            mapImageURL: summary.mapImageURL.flatMap(URL.init(string:)),

            // MARK: - 기타
            feed: nil
        )
    }
}

// MARK: - Formatter Helpers
private extension RunningDetailViewStateMapper {
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd · a hh:mm"
        return formatter.string(from: date)
    }
    
    static func formatDistance(_ distanceMeters: Double) -> String {
        let km = distanceMeters / 1000
        return String(format: "%.2fkm", km)
    }
    
    static func formatDuration(_ duration: Duration) -> String {
        let totalSeconds = Int(duration.components.seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    static func formatPace(_ paceSecPerKm: Double) -> String {
        let totalSeconds = Int(paceSecPerKm)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
    
    static func toViewState(_ coordinate: RunningCoordinate, pace: Double) -> RunningCoordinateViewState {
        RunningCoordinateViewState(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            paceSecPerKm: pace
        )
    }
}
