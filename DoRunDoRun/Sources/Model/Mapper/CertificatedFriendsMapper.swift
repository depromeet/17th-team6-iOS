//
//  CertificatedFriendsMapper.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//

import Foundation

enum CertificatedFriendsMapper {
    static func toDomain(_ entity: CerificatedFriendsContainerEntity) -> [CertificatedFriend] {
        let formatter = ISO8601DateFormatter()
        return entity.data.users.map { user in

            CertificatedFriend(
                userId: user.userId,
                userName: user.userName,
                userImageUrl: URL(string: user.userImageUrl),
                postingTime: formatter.date(from: user.postingTime),
                isMe: user.isMe
            )
        }
    }

    static func toViewModel(_ domain: CertificatedFriend) -> CertificatedFriendViewModel {
        let now = Date()
        let timeInterval = now.timeIntervalSince(domain.postingTime ?? .now)
        let daysAgo = Int(timeInterval / 86400) // 86400 seconds = 1 day

        return CertificatedFriendViewModel(
            userID: domain.userId,
            name: domain.userName,
            imageUrl: domain.userImageUrl,
            daysAgo: daysAgo,
            isMe: domain.isMe
        )
    }
}
