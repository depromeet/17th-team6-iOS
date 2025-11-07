//
//  TokenManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation

/// 앱 전역에서 access/refresh token을 관리하는 객체
final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    @UserDefault(key: "accessToken", defaultValue: nil)
    var accessToken: String?

    @UserDefault(key: "refreshToken", defaultValue: nil)
    var refreshToken: String?
    
    func clear() {
        accessToken = ""
        refreshToken = ""
    }
}
