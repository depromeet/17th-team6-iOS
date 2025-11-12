//
//  RunningSessionSummaryViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/05/25.
//

import Foundation

// MARK: - CertificationStatus
/// 러닝 세션의 인증 상태를 나타내는 열거형
enum CertificationStatus: Equatable {
    /// 인증 가능 (오늘 생성된 세션)
    case possible
    /// 인증 완료 (이미 셀피 인증 완료된 세션)
    case completed
    /// 인증 불가 또는 인증 대상 아님
    case none
}

// MARK: - RunningSessionSummaryViewState
/// 러닝 세션 요약 정보를 화면에 표시하기 위한 View 전용 상태 모델
struct RunningSessionSummaryViewState: Identifiable, Equatable {
    /// 러닝 세션 고유 ID
    let id: Int
    /// 세션 날짜 (Date 객체)
    let date: Date
    /// 표시용 날짜 문자열 (예: "2025.09.30)")
    let dateText: String
    /// 표시용 시간 문자열 (예: "오전 10:11")
    let timeText: String
    /// 달린 거리 텍스트 (예: "8.02km")
    let distanceText: String
    /// 총 러닝 시간 텍스트 (예: "01:12:03")
    let durationText: String
    /// 평균 페이스 텍스트 (예: "6'45\"")
    let paceText: String
    /// 평균 케이던스 텍스트 (예: "128 spm")
    let spmText: String
    /// 인증 상태 (예: 인증 가능, 완료, 또는 없음)
    let tagStatus: CertificationStatus
    /// 지도 이미지 URL (러닝 경로 미리보기용)
    let mapImageURL: String?
}
