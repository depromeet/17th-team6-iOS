//
//  APIConfig.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/05/25.
//

import Foundation

/// 앱의 네트워크 설정을 중앙에서 관리하는 객체
enum APIConfig {
    /// Info.plist의 BASE_URL 값을 읽어와 URL로 변환
    static var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨 BASE_URL not found or invalid in Info.plist")
        }
        return url
    }
}
