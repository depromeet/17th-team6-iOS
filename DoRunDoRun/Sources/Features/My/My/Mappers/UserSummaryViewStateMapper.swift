//
//  UserSummaryViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

struct UserSummaryViewStateMapper {
    static func map(from entity: UserSummary) -> UserSummaryViewState {
        return UserSummaryViewState(
            name: entity.name,
            profileImageURL: entity.profileImageUrl,
            friendCountText: "\(entity.friendCount)명",
            totalDistanceText: String(format: "%.1fkm", entity.totalDistance / 1000),
            selfieCountText: "\(entity.selfieCount)회"
        )
    }
}
