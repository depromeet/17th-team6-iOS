//
//  APIConfig.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation

enum APIConfig {
    static var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨 BASE_URL not found or invalid in Info.plist")
        }
        return url
    }
    
    static var admobBannerAdUnitID: String {
        guard let value = Bundle.main.object(
            forInfoDictionaryKey: "ADMOB_BANNER_AD_UNIT_ID"
        ) as? String else {
            fatalError("🚨 ADMOB_BANNER_AD_UNIT_ID not found in Info.plist")
        }
        return value
    }
}
