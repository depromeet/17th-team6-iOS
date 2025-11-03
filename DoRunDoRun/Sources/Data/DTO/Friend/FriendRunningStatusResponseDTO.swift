//
//  FriendRunningStatusResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

// MARK: - Response Root
struct FriendRunningStatusResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: FriendRunningStatusDataDTO
}

struct FriendRunningStatusDataDTO: Decodable {
    let contents: [FriendRunningStatusContentDTO]
    let meta: FriendRunningStatusMetaDTO
}

// MARK: - Contents
struct FriendRunningStatusContentDTO: Decodable {
    let userId: Int
    let nickname: String
    let isMe: Bool
    let profileImage: String?
    let latestRanAt: String?
    let distance: Double?
    let latitude: Double?
    let longitude: Double?
    let address: String?
}

// MARK: - Meta
struct FriendRunningStatusMetaDTO: Decodable {
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let first: Bool
    let last: Bool
    let hasNext: Bool
    let hasPrevious: Bool
}

// MARK: - Mapping to Domain
extension FriendRunningStatusContentDTO {
    func toDomain() -> FriendRunningStatus {
        FriendRunningStatus(
            id: userId,
            nickname: nickname,
            isMe: isMe,
            profileImageURL: profileImage,
            latestRanAt: ISO8601DateFormatter().date(from: latestRanAt ?? ""),
            distance: distance,
            latitude: latitude,
            longitude: longitude,
            address: address
        )
    }
}
