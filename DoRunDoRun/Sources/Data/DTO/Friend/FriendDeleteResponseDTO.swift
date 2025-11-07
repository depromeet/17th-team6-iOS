//
//  FriendDeleteResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

struct FriendDeleteResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: DeletedFriendsData

    struct DeletedFriendsData: Decodable {
        let deletedFriends: [String: String]
    }
}

extension FriendDeleteResponseDTO {
    func toDomain() -> FriendDeleteResult {
        let deletedList = data.deletedFriends.compactMap { (idString, nickname) -> FriendDeleteResult.DeletedFriend? in
            guard let id = Int(idString) else { return nil }
            return .init(id: id, nickname: nickname)
        }

        return .init(deletedFriends: deletedList)
    }
}
