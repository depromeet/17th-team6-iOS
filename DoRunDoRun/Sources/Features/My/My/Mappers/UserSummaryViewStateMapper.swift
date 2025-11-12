//
//  UserSummaryViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

struct UserSummaryViewStateMapper {
    static func map(from entity: UserSummary) -> UserSummaryViewState {
        let runningFormatter = RunningFormatterManager.shared
        
        return UserSummaryViewState(
            name: entity.name,
            profileImageURL: entity.profileImageUrl,
            friendCountText: "\(entity.friendCount)명",
            totalDistanceText: runningFormatter.formatDistance(from: entity.totalDistance),
            selfieCountText: "\(entity.selfieCount)회"
        )
    }
}
