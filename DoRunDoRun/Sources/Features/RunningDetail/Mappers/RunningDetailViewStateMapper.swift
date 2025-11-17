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
        let dateFormatter = DateFormatterManager.shared
        let runningFormatter = RunningFormatterManager.shared
        
        // 전역 포맷 사용
        let startedAtText = dateFormatter.formatDateTime(from: detail.startedAt)
        let distanceText = runningFormatter.formatDistance(from: detail.totalDistanceMeters)
        let elapsedText = runningFormatter.formatDuration(from: Int(detail.elapsed.components.seconds))
        let paceText = runningFormatter.formatPace(from: detail.avgPaceSecPerKm)
        let cadenceText = runningFormatter.formatCadence(from: detail.avgCadenceSpm)
        
        let points = detail.coordinates.map {
            RunningCoordinateViewState(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude,
                paceSecPerKm: RunningConverterManager.speedToPace($0.speedMps) ?? 0
            )
        }
        print("🐯: \(points)")
        
        return RunningDetailViewState(
            sessionId: detail.sessionId,
            startedAtText: startedAtText,
            totalDistanceText: distanceText,
            avgPaceText: paceText,
            durationText: elapsedText,
            cadenceText: cadenceText,

            startedAt: detail.startedAt,
            finishedAt: detail.finishedAt,
            totalDistanceMeters: detail.totalDistanceMeters,
            elapsed: detail.elapsed,
            avgPaceSecPerKm: detail.avgPaceSecPerKm,
            avgCadenceSpm: detail.avgCadenceSpm,
            maxCadenceSpm: detail.maxCadenceSpm,
            fastestPaceSecPerKm: detail.fastestPaceSecPerKm,
            coordinateAtmaxPace: detail.coordinateAtmaxPace,

            points: points,
            mapImageData: detail.mapImageData,
            mapImageURL: detail.mapImageURL,

            feed: detail.feed
        )
    }
    
    /// ViewState → ViewState
    static func map(from detail: RunningDetailViewState) -> RunningSessionSummaryViewState {
        let formatter = DateFormatterManager.shared

        return RunningSessionSummaryViewState(
            id: detail.sessionId ?? 0,
            date: detail.startedAt,
            dateText: formatter.formatDateWithWeekdayText(from: detail.startedAt),
            timeText: formatter.formatTime(from: detail.startedAt),
            distanceText: RunningFormatterManager.shared.formatDistance(from: detail.totalDistanceMeters),
            durationText: RunningFormatterManager.shared.formatDuration(from: Int(detail.elapsed.components.seconds)),
            paceText: RunningFormatterManager.shared.formatPace(from: detail.avgPaceSecPerKm),
            spmText: RunningFormatterManager.shared.formatCadence(from: detail.avgCadenceSpm),
            tagStatus: .possible, // 인증 피드 생성 화면임으로 항상 인증 가능 상태일 것
            mapImageURL: detail.mapImageURL
        )
    }

    /// ViewState → RunningCompleteRequest (서버 완료 요청용)
    static func toCompleteRequest(from viewState: RunningDetailViewState) -> RunningCompleteRequest {
        RunningCompleteRequest(
            totalDistanceMeters: viewState.totalDistanceMeters,
            elapsed: viewState.elapsed,
            avgPaceSecPerKm: viewState.avgPaceSecPerKm,
            fastestPaceSecPerKm: viewState.fastestPaceSecPerKm,
            coordinateAtMaxPace: viewState.coordinateAtmaxPace.coordinate,
            avgCadenceSpm: viewState.avgCadenceSpm,
            maxCadenceSpm: viewState.maxCadenceSpm
        )
    }
}
