//
//  UserProfileResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation

struct UserProfileResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: UserProfileDataDTO
}

struct UserProfileDataDTO: Decodable {
    let id: Int
    let nickname: String
    let profileImageUrl: String?
    let code: String
    let phoneNumberFormatted: String
    let createdAt: String
}

// MARK: - Mapping to Domain
extension UserProfileDataDTO {
    func toDomain() -> UserProfile {
        .init(
            id: id,
            nickname: nickname,
            profileImageURL: profileImageUrl,
            code: code,
            phoneNumber: phoneNumberFormatted,
            createdAt: createdAt
        )
    }
}
