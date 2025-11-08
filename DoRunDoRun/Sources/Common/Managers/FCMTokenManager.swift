//
//  FCMTokenManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

/// 앱 전역에서 FCM 토큰을 관리하는 객체
final class FCMTokenManager {
    static let shared = FCMTokenManager()
    private init() {}
    
    @UserDefault(key: "fcmToken", defaultValue: nil)
    var fcmToken: String?
    
    func clear() {
        fcmToken = nil
    }
}
