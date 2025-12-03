//
//  RunningSnapshotViewStateMapper.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/22/25.
//

/// Mapper: RunningSnapshot -> RunningSnapshotViewState
struct RunningSnapshotViewStateMapper {
    static func map(from snapshot: RunningSnapshot) -> RunningSnapshotViewState {
        let distanceText = makeDistanceText(fromMeters: snapshot.metrics.totalDistanceMeters)
        let paceText = makePaceText(
            avgPaceSecPerKm: snapshot.metrics.currentPaceSecPerKm,
            distanceMeters: snapshot.metrics.totalDistanceMeters
        )
        let durationText = makeDurationText(from: snapshot.metrics.elapsed)
        let cadenceText = makeCadenceText(from: snapshot.metrics.currentCadenceSpm)
        let lastCoordinate = makeLastCoordinate(from: snapshot)

        return RunningSnapshotViewState(
            distanceText: distanceText,
            paceText: paceText,
            durationText: durationText,
            cadenceText: cadenceText,
            lastCoordinate: lastCoordinate
        )
    }

    // MARK: - Formatting helpers

    /// 거리(m)를 "x.xxkm" 스타일로 변환 (항상 소수점 2자리, 공백 없음)
    private static func makeDistanceText(fromMeters meters: Double) -> String {
        let km = meters / 1000.0
        return String(format: "%.2fkm", km)
    }

    /// 평균 페이스(초/킬로미터)를 "m'ss''"로 변환, 거리 0 또는 pace 0이면 "0'00''"
    private static func makePaceText(avgPaceSecPerKm paceSecPerKm: Double, distanceMeters: Double) -> String {
        let pace = max(0, paceSecPerKm)
        guard distanceMeters > 0, pace > 0 else { return "0'00''" }
        let totalSeconds = Int(pace.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d'%02d''", minutes, seconds)
    }

    /// 경과 시간(Duration)을 "H:mm:ss"로 변환
    private static func makeDurationText(from elapsed: Duration) -> String {
        let totalSeconds = Int(elapsed.components.seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    /// 케이던스(sppm)를 "154 spm"처럼 정수로 변환
    private static func makeCadenceText(from cadenceSpm: Double) -> String {
        String(format: "%.0f spm", cadenceSpm)
    }

    /// 마지막 좌표를 CoordinateViewState로 생성 (페이스 정보 포함)
    private static func makeLastCoordinate(from snapshot: RunningSnapshot) -> RunningCoordinateViewState? {
        guard let point = snapshot.lastPoint else { return nil }
        return .init(
            latitude: point.coordinate.latitude,
            longitude: point.coordinate.longitude,
            paceSecPerKm: snapshot.metrics.currentPaceSecPerKm
        )
    }
}
