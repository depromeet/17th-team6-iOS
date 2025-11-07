//
//  FriendDeleteResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

struct FriendDeleteResponseDTO: Codable {
    let status: String
    let message: String
    let timestamp: String
    let data: EmptyData

    struct EmptyData: Codable { }
}
