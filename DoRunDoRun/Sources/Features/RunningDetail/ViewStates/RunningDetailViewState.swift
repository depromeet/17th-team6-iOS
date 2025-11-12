//
//  RunningDetailViewState.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/31/25.
//

import Foundation

struct RunningDetailViewState: Equatable {
    // MARK: - 세션 정보
    let sessionId: Int?

    // MARK: - 화면 표시용 Formatted String
    let finishedAtText: String
    let totalDistanceText: String
    let avgPaceText: String
    let durationText: String
    let cadenceText: String

    // MARK: - 원본 Domain 값 (서버 전송용)
    let startedAt: Date
    let finishedAt: Date
    let totalDistanceMeters: Double
    let elapsed: Duration
    let avgPaceSecPerKm: Double
    let avgCadenceSpm: Double
    let maxCadenceSpm: Double
    let fastestPaceSecPerKm: Double
    let coordinateAtmaxPace: RunningPoint

    // MARK: - 지도 관련
    let points: [RunningCoordinateViewState]
    let coordinates: [RunningCoordinate]  // Domain 좌표 (서버 전송용)
    var mapImageData: Data?
    var mapImageURL: URL?

    // MARK: - 기타
    let feed: FeedSummary?

    /// 기록 인증 버튼 표시 여부 (당일 시작한 러닝만)
    var shouldShowRecordButton: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(startedAt) && feed == nil
    }
}
