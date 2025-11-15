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
    
    @UserDefault(key: "profileImageURL", defaultValue: nil)
    var profileImageURL: String?
    
    @UserDefault(key: "isMarketingPushOn", defaultValue: false)
    var isMarketingPushOn: Bool

    @UserDefault(key: "marketingAgreementDate", defaultValue: nil)
    var marketingAgreementDate: String?

    func clear() {
        userId = 0
        nickname = ""
        profileImageURL = nil
    }
}
