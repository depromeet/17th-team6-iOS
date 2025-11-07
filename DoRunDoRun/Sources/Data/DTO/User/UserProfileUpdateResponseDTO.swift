//
//  UserProfileUpdateResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

struct UserProfileUpdateResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: UpdatedProfileDataDTO

    struct UpdatedProfileDataDTO: Decodable {
        let profileImageUrl: String?
    }
}
