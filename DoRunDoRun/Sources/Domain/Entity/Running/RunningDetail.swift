//
//  RunningDetail.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/31/25.
//

import Foundation

struct RunningDetail: Equatable {
    /// 서버 세션 ID (로컬 추적만 한 경우 nil)
    let sessionId: Int?
    /// 달리기 시작 시간
    let startedAt: Date
    /// 달리기 종료 시각
    let finishedAt: Date
    /// 누적 이동거리 (m)
    let totalDistanceMeters: Double
    /// 누적 경과시간 (일시정지 제외)
    let elapsed: Duration
    /// 평균 페이스 (초/킬로미터)
    let avgPaceSecPerKm: Double
    /// 평균 케이던스 (steps/min)
    let avgCadenceSpm: Double
    /// 최대 케이던스 (steps/min)
    let maxCadenceSpm: Double
    /// 최대 페이스 (초/킬로미터, 작을수록 빠름)
    let fastestPaceSecPerKm: Double
    /// 최대 페이스 시점의 좌표 정보
    let coordinateAtmaxPace: RunningPoint
    /// 전체 경로 좌표 정도
    let coordinates: [RunningCoordinate]
    
    // 지도 이미지
    var mapImageData: Data?
    let mapImageURL: URL?
    
    // MARK: - 우선 임시 작성 (피드 작업이 마무리 되면 바꾸기)
    let feed: FeedSummary?
}
// MARK: - 우선 임시 작성 (피드 작업이 마무리 되면 바꾸기)
struct FeedSummary: Equatable, Sendable {
    let id: Int
    let mapImageURL: URL?
    let selfieImageURL: URL?
    let content: String?
    let createdAt: Date
}

#if DEBUG
extension RunningDetail {
    static let mock = RunningDetail(
        sessionId: 123,
        startedAt: Date(),
        finishedAt: Date().addingTimeInterval(3600),
        totalDistanceMeters: 3210.5,
        elapsed: .seconds(900), // 15분
        avgPaceSecPerKm: 280.0, // 약 4분40초/km
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
        mapImageData: nil, mapImageURL: nil,
        feed: nil
    )
}
#endif
