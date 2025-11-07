//
//  UserProfileUpdateRequestDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

struct UserProfileUpdateRequestDTO: Encodable {
    let nickname: String
    let imageOption: ImageOption

    enum ImageOption: String, Encodable {
        case set = "SET"
        case keep = "KEEP"
        case remove = "REMOVE"
    }
}
