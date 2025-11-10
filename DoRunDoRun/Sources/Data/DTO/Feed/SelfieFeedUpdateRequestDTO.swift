//
//  SelfieFeedUpdateRequestDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

/// 인증피드 수정 요청 DTO
struct SelfieFeedUpdateRequestDTO: Encodable {
    /// 인증피드 내용
    let content: String
    /// 달리기 거리 (예: 5.32)
    let totalDistance: Double
    /// 달리기 시간 (예: 3600초)
    let totalTime: Int
    /// 평균 페이스 (예: "6'00\"")
    let averagePace: String
    /// 평균 케이던스 (예: 175)
    let averageCadence: Int
    /// 달리기 날짜 (ISO8601 문자열)
    let runningDate: String
    /// 달리기 시작 시간 (예: "2025-11-10T10:30:00Z")
    let startTime: String
    /// 달리기 종료 시간 (예: "2025-11-10T11:00:00Z")
    let endTime: String
    
    init(
        content: String,
        totalDistance: Double,
        totalTime: Int,
        averagePace: String,
        averageCadence: Int,
        runningDate: String,
        startTime: String,
        endTime: String
    ) {
        self.content = content
        self.totalDistance = totalDistance
        self.totalTime = totalTime
        self.averagePace = averagePace
        self.averageCadence = averageCadence
        self.runningDate = runningDate
        self.startTime = startTime
        self.endTime = endTime
    }
}
