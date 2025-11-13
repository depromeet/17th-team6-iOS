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

        // 결과 화면에서는 전체 평균 페이스를 모든 좌표에 적용
        let points = detail.coordinates.map {
            RunningCoordinateViewState(
                latitude: $0.latitude,
                longitude: $0.longitude,
                paceSecPerKm: detail.avgPaceSecPerKm
            )
        }

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
            coordinates: detail.coordinates,
            mapImageData: detail.mapImageData,
            mapImageURL: detail.mapImageURL,

            feed: detail.feed
        )
    }

    /// ViewState → Domain (Reverse Mapping)
    static func toDomain(from viewState: RunningDetailViewState) -> RunningDetail {
        RunningDetail(
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
}
