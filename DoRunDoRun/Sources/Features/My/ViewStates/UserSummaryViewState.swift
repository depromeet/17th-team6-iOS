//
//  UserSummaryViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

// MARK: - UserSummaryViewState
/// 피드 상단 유저 요약 정보 View 전용 상태 모델
struct UserSummaryViewState: Equatable {
    /// 사용자 이름
    let name: String

    /// 프로필 이미지 URL (없을 경우 기본 이미지 표시)
    let profileImageURL: String?

    /// 친구 수 텍스트 (예: "7명")
    let friendCountText: String

    /// 총 거리 텍스트 (예: "12.3km")
    let totalDistanceText: String

    /// 총 셀피 개수 텍스트 (예: "42회")
    let selfieCountText: String
}
