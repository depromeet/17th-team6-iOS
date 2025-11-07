//
//  UserProfile.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation

struct UserProfile: Equatable {
    let id: Int
    let nickname: String
    let profileImageURL: String?
    let code: String
    let phoneNumber: String
    let createdAt: String
}
