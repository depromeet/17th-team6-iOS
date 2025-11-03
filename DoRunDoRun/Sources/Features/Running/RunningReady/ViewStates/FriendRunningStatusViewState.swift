//
//  FriendRunningStatusViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import Foundation

struct FriendRunningStatusViewState: Identifiable, Equatable {
    /// 친구를 구분하기 위한 고유 식별자
    let id: Int

    /// 친구의 닉네임 (자신일 경우 '나'로 표시될 수도 있음)
    let name: String

    /// 현재 사용자인지 여부 (`true`이면 본인)
    let isMe: Bool

    /// 친구의 프로필 이미지 URL (없을 경우 `nil`)
    let profileImageURL: String?

    /// 가장 최근 러닝 시간 정보를 문자열 형태로 표시 (예: "1시간 전")
    let latestRanText: String?
    
    /// 마지막 응원 시간
    let latestCheeredAt: Date?

    /// 현재 러닝 중인지 여부 (`true`이면 러닝 중)
    let isRunning: Bool
    
    /// 깨우기 버튼 활성화 여부
    var isCheerable: Bool

    /// 누적 거리 또는 최근 러닝 거리 문자열 (예: "5.2km")
    let distanceText: String?

    /// 친구의 위도 좌표 (지도 표시용)
    let latitude: Double?

    /// 친구의 경도 좌표 (지도 표시용)
    let longitude: Double?
    
    /// 친구의 주소 정보 (예: "서울 마포구")
    let address: String?
}

