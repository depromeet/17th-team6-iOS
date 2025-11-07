//
//  FriendCodeResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

struct FriendCodeResponseDTO: Codable {
    let data: FriendCodeDataDTO

    struct FriendCodeDataDTO: Codable {
        let userId: Int
    }
}
