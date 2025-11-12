//
//  SelfieUsersByDateResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation

struct SelfieUsersByDateResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: DataClass
    
    struct DataClass: Decodable {
        let users: [UserDTO]
    }
}

struct UserDTO: Decodable {
    let userId: Int
    let userName: String
    let userImageUrl: String
    let postingTime: String
    let isMe: Bool
}

extension UserDTO {
    func toDomain() -> SelfieUserResult {
        SelfieUserResult(
            id: userId,
            name: userName,
            profileImageUrl: userImageUrl,
            postingTime: postingTime,
            isMe: isMe
        )
    }
}
