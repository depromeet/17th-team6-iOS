//
//  FriendReactionResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

struct FriendReactionResponseDTO: Decodable {
    let status: String?
    let message: String?
    let timestamp: String?
    let data: [String: String]?
}
