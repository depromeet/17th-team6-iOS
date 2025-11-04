//
//  NotificationAPI.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import Foundation
import Moya

enum NotificationAPI {
    case notifications(page: Int, size: Int)
    case notificationRead(notificationId: Int)
}

extension NotificationAPI: TargetType {
    var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨 BASE_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .notifications: return "/api/notifications"
        case let .notificationRead(notificationId): return "/api/notifications/\(notificationId)/read"
        }
    }

    var method: Moya.Method {
        switch self {
        case .notifications: return .get
        case .notificationRead: return .patch
        }
    }

    var task: Task {
        switch self {
        case let .notifications(page, size):
            return .requestParameters(
                parameters: [
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.default
            )
        case .notificationRead:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
