//
//  NetworkConstants.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

import Alamofire

enum NetworkConstants {
    static let baseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("🚨 BASE_URL not found in Info.plist")
        }
        return url
    }()

    static var defaultHeaders: HTTPHeaders {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
