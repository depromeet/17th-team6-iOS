//
//  FriendAPI.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

import Moya

enum FriendAPI {
    case runningStatus(page: Int, size: Int)
    case reaction(userId: Int)
}

extension FriendAPI: TargetType {
    // MARK: - Base URL
    var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨 BASE_URL not found or invalid in Info.plist")
        }
        return url
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .runningStatus:
            return "/api/friends/running/status"
        case .reaction:
            return "/api/friends/reaction"
        }
    }

    // MARK: - Method
    var method: Moya.Method {
        switch self {
        case .runningStatus:
            return .get
        case .reaction:
            return .post
        }
    }

    // MARK: - Task
    var task: Task {
        switch self {
        case let .runningStatus(page, size):
            // GET 요청은 쿼리스트링으로 전달
            return .requestParameters(
                parameters: ["page": page, "size": size],
                encoding: URLEncoding.queryString
            )

        case let .reaction(userId):
            // POST 요청은 JSON body로 전달
            return .requestParameters(
                parameters: ["userId": userId],
                encoding: JSONEncoding.default
            )
        }
    }

    // MARK: - Headers
    var headers: [String : String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
