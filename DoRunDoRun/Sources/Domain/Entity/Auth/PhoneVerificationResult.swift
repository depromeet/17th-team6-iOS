//
//  PhoneVerificationResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/27/25.
//

struct PhoneVerificationResult: Equatable {
    let phoneNumber: String
    let isExistingUser: Bool
    let user: User
    let token: Token
}

struct User: Equatable {
    let id: Int
    let nickname: String
}

struct Token: Equatable {
    let accessToken: String
    let refreshToken: String
}
