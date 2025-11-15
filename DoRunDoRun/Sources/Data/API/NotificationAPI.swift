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
    case unreadCount
}

extension NotificationAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .notifications: 
            return "/api/notifications"
        case let .notificationRead(notificationId):
            return "/api/notifications/\(notificationId)/read"
        case .unreadCount:
             return "/api/notifications/unread-count"
        }
    }

    var method: Moya.Method {
        switch self {
        case .notifications: return .get
        case .notificationRead: return .patch
        case .unreadCount: return .get
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
        case .notificationRead, .unreadCount:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        HTTPHeader.json.value
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
