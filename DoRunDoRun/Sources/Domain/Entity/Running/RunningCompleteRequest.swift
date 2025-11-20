//
//  RunningCompleteRequest.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/17/25.
//

import Foundation

/// 러닝 세션 완료 요청에 필요한 데이터를 담는 Value Object
/// 서버 API 호출 시 필요한 최소한의 정보만 포함
struct RunningCompleteRequest {
    /// 누적 이동거리 (m)
    let totalDistanceMeters: Double
    /// 누적 경과시간 (일시정지 제외)
    let elapsed: Duration
    /// 평균 페이스 (초/킬로미터)
    let avgPaceSecPerKm: Double
    /// 최대 페이스 (초/킬로미터, 작을수록 빠름)
    let fastestPaceSecPerKm: Double
    /// 최대 페이스 시점의 좌표 정보
    let coordinateAtMaxPace: RunningCoordinate
    /// 평균 케이던스 (steps/min)
    let avgCadenceSpm: Double
    /// 최대 케이던스 (steps/min)
    let maxCadenceSpm: Double
}
