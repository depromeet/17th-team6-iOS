//
//  CertificatedFriendsEntity.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//

import Foundation

struct CerificatedFriendsContainerEntity: Decodable {
    let status, message, timestamp: String
    let data: FriendEmptyContainer
}

// MARK: - DataClass
struct FriendEmptyContainer: Decodable {
    let users: [CertificatedFriendEntity]
}

// MARK: - User
struct CertificatedFriendEntity: Decodable {
    let userId: Int
    let userName: String
    let userImageUrl: String
    let postingTime: String
    let isMe: Bool
}
