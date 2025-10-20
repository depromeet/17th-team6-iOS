//
//  FriendRunningStatus.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

/// 유저 및 친구의 러닝 상태 Entity
struct FriendRunningStatus: Equatable, Identifiable {
    let id: Int
    let nickname: String
    let isMe: Bool
    let profileImageURL: URL?
    let latestRanAt: Date?
    let distance: Double?
    let latitude: Double?
    let longitude: Double?
}
