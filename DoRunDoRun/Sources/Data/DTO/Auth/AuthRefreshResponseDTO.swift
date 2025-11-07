//
//  AuthRefreshResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

struct AuthRefreshResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: AuthRefreshDataDTO
}

struct AuthRefreshDataDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
