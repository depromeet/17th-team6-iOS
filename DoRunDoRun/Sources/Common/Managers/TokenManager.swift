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

    @UserDefault(key: "ACCESS_TOKEN", defaultValue: "")
    var accessToken: String

    @UserDefault(key: "REFRESH_TOKEN", defaultValue: "")
    var refreshToken: String

    func clear() {
        accessToken = ""
        refreshToken = ""
    }
}
