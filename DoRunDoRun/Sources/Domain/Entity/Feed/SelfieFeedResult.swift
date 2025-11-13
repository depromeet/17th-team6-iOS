//
//  SelfieFeedResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

/// 셀피 피드 조회 결과 (도메인 루트 모델)
/// - `userSummary`: 피드 상단에 표시될 유저 요약 정보
/// - `feeds`: 실제 피드(게시물) 리스트
struct SelfieFeedResult: Equatable {
    let userSummary: UserSummary?
    let feeds: [SelfieFeed]
}

/// 유저 요약 정보
/// 셀피 피드 상단 헤더 영역(내 친구 수, 총 거리 등)에 표시되는 요약 데이터
struct UserSummary: Equatable {
    /// 사용자 이름
    let name: String
    /// 프로필 이미지 URL (없을 수도 있음)
    let profileImageUrl: String?
    /// 친구 수
    let friendCount: Int
    /// 총 달린 거리 (km)
    let totalDistance: Double
    /// 총 셀피 개수
    let selfieCount: Int
}

/// 개별 셀피 피드 (러닝 인증 게시물)
/// 피드 리스트의 각 아이템에 해당하는 데이터
struct SelfieFeed: Equatable, Identifiable {
    /// 피드 고유 ID
    let id: Int
    /// 날짜 (ex. "2025-11-06")
    let date: String
    /// 작성자 이름
    let userName: String
    /// 작성자 프로필 이미지
    let profileImageUrl: String
    /// 내가 작성한 피드인지 여부
    let isMyFeed: Bool
    /// 셀피 촬영 시각 (서버에서 받은 값 그대로)
    let selfieTime: String
    /// 달린 총 거리 (km)
    let totalDistance: Double
    /// 총 달린 시간 (초 단위)
    let totalRunTime: Double
    /// 평균 페이스 (초/킬로미터)
    let averagePace: Double
    /// 평균 케이던스 (spm)
    let cadence: Int
    /// 게시물 이미지 URL (지도 이미지 또는 셀피)
    var imageUrl: String
    /// 리액션(이모지 반응) 리스트
    let reactions: [Reaction]
}

/// 리액션 정보
/// 각 피드에 달린 반응(이모지별 카운트 및 참여자)
struct Reaction: Equatable {
    /// 리액션 이모지 타입
    let emojiType: EmojiType
    /// 총 리액션 수
    let totalCount: Int
    /// 현재 사용자가 리액션을 눌렀는지 여부
    let isReactedByMe: Bool
    /// 이 리액션을 누른 유저 목록
    let users: [ReactionUser]
}

/// 리액션을 누른 유저 정보
struct ReactionUser: Equatable {
    /// 유저 고유 ID
    let userId: Int
    /// 닉네임
    let nickname: String
    /// 프로필 이미지 URL
    let profileImageUrl: String
    /// 현재 로그인한 유저인지 여부
    let isMe: Bool
    /// 리액션을 누른 시각 (ISO8601 문자열)
    let reactedAt: String
}

/// 지원되는 리액션 이모지 타입
/// 서버에서 전달되는 문자열(`"HEART"`, `"FIRE"`, 등)에 대응
enum EmojiType: String, Equatable {
    case surprise = "SURPRISE"   // 놀람
    case heart = "HEART"         // 하트
    case thumbsUp = "THUMBS_UP"  // 엄지
    case congrats = "CONGRATS"   // 축하
    case fire = "FIRE"           // 불
}
