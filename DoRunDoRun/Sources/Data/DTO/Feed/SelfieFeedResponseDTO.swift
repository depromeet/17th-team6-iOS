//
//  SelfieFeedResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

/// 셀피 피드 API 전체 응답 구조
/// 서버 응답의 최상위 루트
struct SelfieFeedResponseDTO: Codable {
    let status: String
    let message: String
    let timestamp: String
    let data: SelfieFeedDataDTO
}

/// 셀피 피드 데이터 컨테이너
/// 유저 요약 정보 + 피드 리스트를 함께 담고 있음
struct SelfieFeedDataDTO: Codable {
    let userSummary: UserSummaryDTO?
    let feeds: SelfieFeedContainerDTO
}

/// 유저 요약 정보 DTO
/// 셀피 피드 상단 헤더용 요약 데이터
struct UserSummaryDTO: Codable {
    let name: String
    let profileImageUrl: String
    let friendCount: Int
    let totalDistance: Double
    let selfieCount: Int
}

/// 피드 컨테이너 (페이지네이션 포함)
/// 실제 피드 리스트와 페이지 메타 정보를 포함
struct SelfieFeedContainerDTO: Codable {
    let contents: [SelfieFeedDTO]
    let meta: MetaDTO
}

/// 개별 셀피 피드 데이터
/// 하나의 피드(러닝 인증 게시물)에 대한 상세 정보
struct SelfieFeedDTO: Codable {
    let feedId: Int
    let date: String
    let userName: String
    let profileImageUrl: String
    let isMyFeed: Bool
    let selfieTime: String
    let totalDistance: Double
    let totalRunTime: Double
    let averagePace: Double
    let cadence: Int
    let imageUrl: String
    let reactions: [ReactionDTO]
}

/// 리액션 DTO
/// 각 피드에 달린 리액션(이모지 종류, 카운트, 유저 목록)
struct ReactionDTO: Codable {
    let emojiType: String
    let totalCount: Int
    let isReactedByMe: Bool
    let users: [ReactionUserDTO]
}

/// 리액션을 누른 유저 정보 DTO
struct ReactionUserDTO: Codable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String
    let isMe: Bool
    let reactedAt: String
}

/// 페이지네이션 메타 데이터
struct MetaDTO: Codable {
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let first: Bool
    let last: Bool
    let hasNext: Bool
    let hasPrevious: Bool
}

// MARK: - Domain Mapping Extensions

/// UserSummaryDTO → UserSummary
extension UserSummaryDTO {
    /// 서버 DTO를 도메인 엔티티로 변환
    func toDomain() -> UserSummary {
        .init(
            name: name,
            profileImageUrl: profileImageUrl,
            friendCount: friendCount,
            totalDistance: totalDistance,
            selfieCount: selfieCount
        )
    }
}

/// SelfieFeedDTO → SelfieFeed
extension SelfieFeedDTO {
    /// 서버 DTO를 도메인 모델로 매핑
    func toDomain() -> SelfieFeed {
        .init(
            id: feedId,
            date: date,
            userName: userName,
            profileImageUrl: profileImageUrl,
            isMyFeed: isMyFeed,
            selfieTime: selfieTime,
            totalDistance: totalDistance,
            totalRunTime: totalRunTime,
            averagePace: averagePace,
            cadence: cadence,
            imageUrl: imageUrl,
            reactions: reactions.map { $0.toDomain() } // ReactionDTO 리스트 매핑
        )
    }
}

/// ReactionDTO → Reaction
extension ReactionDTO {
    /// 서버 DTO를 도메인 리액션 모델로 변환
    func toDomain() -> Reaction {
        .init(
            emojiType: EmojiType(rawValue: emojiType) ?? .surprise,
            totalCount: totalCount,
            isReactedByMe: isReactedByMe,
            users: users.map { $0.toDomain() }  // ReactionUserDTO 리스트 매핑
        )
    }
}

/// ReactionUserDTO → ReactionUser
extension ReactionUserDTO {
    /// 서버 DTO를 도메인 유저 모델로 변환
    func toDomain() -> ReactionUser {
        .init(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            isMe: isMe,
            reactedAt: reactedAt
        )
    }
}
