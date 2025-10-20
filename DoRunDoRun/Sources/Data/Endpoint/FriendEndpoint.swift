//
//  FriendAPI.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Alamofire

enum FriendAPI: APIEndpointProtocol {
    case runningStatus(page: Int, size: Int)
    case reaction(userId: Int)

    var path: String {
        switch self {
        case .runningStatus:
            return "/api/friends/running/status"
        case .reaction:
            return "/api/friends/reaction"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .runningStatus:
            return .get
        case .reaction:
            return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .runningStatus(page, size):
            return ["page": page, "size": size]
        case let .reaction(userId):
            return ["userId": userId]
        }
    }
}
