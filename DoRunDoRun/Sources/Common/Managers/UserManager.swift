//
//  UserManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

/// 앱 전역에서 유저의 기본 정보를 관리하는 객체
final class UserManager {
    static let shared = UserManager()
    private init() {}

    @UserDefault(key: "userId", defaultValue: 0)
    var userId: Int
    
    @UserDefault(key: "nickname", defaultValue: "")
    var nickname: String

    func clear() {
        userId = 0
        nickname = ""
    }
}
