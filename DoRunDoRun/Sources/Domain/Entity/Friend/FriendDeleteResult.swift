//
//  FriendDeleteResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

struct FriendDeleteResult: Equatable {
    let deletedFriends: [DeletedFriend]

    struct DeletedFriend: Equatable {
        let id: Int
        let nickname: String
    }
}
