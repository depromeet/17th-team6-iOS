//
//  UserProfileViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

struct UserProfileViewStateMapper {
    static func map(from entity: UserProfile) -> UserProfileViewState {
        let formatter = DateFormatterManager.shared
        let date = formatter.isoDate(from: entity.createdAt) ?? Date()
        return UserProfileViewState(
            nickname: entity.nickname,
            phoneNumber: entity.phoneNumber,
            code: entity.code,
            signUpDate: formatter.formatDateText(from: date),
            profileImageURL: entity.profileImageURL
        )
    }
}
