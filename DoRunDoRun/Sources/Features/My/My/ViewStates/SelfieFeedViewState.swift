//
//  SelfieFeedViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

// MARK: - SelfieFeedViewState
/// 셀피 피드 리스트를 화면에 표시하기 위한 View 전용 상태 모델
struct SelfieFeedViewState: Identifiable, Equatable {
    
    /// 셀 타입 구분 (섹션 헤더 or 피드)
    enum Kind: Equatable {
        /// 월 헤더 셀 (예: "2025년 10월")
        case monthHeader(year: String, month: String)
        /// 실제 피드 셀
        case feed(SelfieFeedItem)
    }

    /// 고유 ID (Kind에 따라 다르게 구성)
    let id: String
    /// 셀 종류 (월 헤더 or 피드)
    var kind: Kind
}

// MARK: - SelfieFeedItem
/// 개별 피드 셀에서 표시할 데이터
struct SelfieFeedItem: Equatable {
    /// 내 피드인지 여부
    let isMyFeed: Bool
    /// 피드 고유 ID
    let feedID: Int
    /// 일자 텍스트 (ex. "15일")
    let dayText: String
    /// 이미지 URL (지도 or 셀피)
    var imageURL: String?
    /// 지도 이미지 여부 (true면 지도 이미지)
    let isMap: Bool

    // MARK: - 상세 표시용 데이터
    /// 작성자 이름
    let userName: String
    /// 프로필 이미지 URL
    let profileImageURL: String
    /// 달린 거리 텍스트 (ex. "8.02km")
    let totalDistanceText: String
    /// 달린 시간 텍스트 (ex. "1:52:06")
    let totalRunTimeText: String
    /// 평균 페이스 텍스트 (ex. "7'30\"")
    let averagePaceText: String
    /// 평균 케이던스 (단위: spm)
    let cadence: Int
    /// 리액션 리스트 (이모지, 카운트, 유저 정보 등)
    var reactions: [ReactionViewState]
    /// 날짜 텍스트 (ex. "2025.10.15")
    let dateText: String
    /// 시간 텍스트 (ex. "오후 1:25")
    let timeText: String
    /// 피드가 작성된 시각을 상대적으로 표시 ("3분 전", "2시간 전" 등)
    let relativeTimeText: String
    
    let selfieDate: Date
}

// MARK: - ReactionViewState
/// 개별 리액션(이모지 + 카운트 + 참여자) View 전용 상태
struct ReactionViewState: Identifiable, Equatable {
    /// 이모지 타입 자체를 ID로 사용 (유니크 보장)
    var id: EmojiType { emojiType }
    /// 리액션 이모지 타입
    let emojiType: EmojiType
    /// 총 리액션 수
    var totalCount: Int
    /// 현재 사용자가 리액션을 눌렀는지 여부
    var isReactedByMe: Bool
    /// 리액션을 누른 유저 리스트
    var users: [ReactionUserViewState]
}

// MARK: - ReactionUserViewState
/// 리액션을 누른 유저를 View 전용으로 표현한 구조체
struct ReactionUserViewState: Identifiable, Equatable {
    /// 유저 고유 ID
    let id: Int
    /// 닉네임
    let nickname: String
    /// 프로필 이미지 URL
    let profileImageUrl: String?
    /// 현재 로그인한 유저인지 여부
    let isMe: Bool
    /// 리액션한 시각 텍스트 (포맷팅 완료 상태, 예: "3분 전")
    let reactedAtText: String
}

extension SelfieFeedItem {
    /// feedID만 알고 있을 때 사용할 empty 객체
    static func empty(feedID: Int) -> SelfieFeedItem {
        SelfieFeedItem(
            isMyFeed: false,
            feedID: feedID,
            dayText: "",
            imageURL: nil,
            isMap: false,
            userName: "",
            profileImageURL: "",
            totalDistanceText: "",
            totalRunTimeText: "",
            averagePaceText: "",
            cadence: 0,
            reactions: [],
            dateText: "",
            timeText: "",
            relativeTimeText: "",
            selfieDate: .init(timeIntervalSince1970: 0)
        )
    }
}
