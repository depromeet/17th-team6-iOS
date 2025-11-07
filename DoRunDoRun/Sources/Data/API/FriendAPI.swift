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
    case deleteFriends(ids: [Int])
    case generateMyFriendCode
    case addFriendByCode(code: String)
}

extension FriendAPI: TargetType {
    // MARK: - Base URL
    var baseURL: URL { APIConfig.baseURL }

    // MARK: - Path
    var path: String {
        switch self {
        case .runningStatus:
            return "/api/friends/running/status"
        case .reaction:
            return "/api/friends/reaction"
        case .deleteFriends:
            return "/api/friends/delete"
        case .generateMyFriendCode:
            return "/api/friends/will-you-friend-me"
        case .addFriendByCode:
            return "/api/friends/will-you-friend-me"
        }
    }

    // MARK: - Method
    var method: Moya.Method {
        switch self {
        case .runningStatus:
            return .get
        case .reaction:
            return .post
        case .deleteFriends:
            return .post
        case .generateMyFriendCode:
            return .get
        case .addFriendByCode:
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
            
        case let .deleteFriends(ids):
            return .requestJSONEncodable(FriendDeleteRequestDTO(friendIds: ids))
            
        case .generateMyFriendCode:
            return .requestPlain
            
        case let .addFriendByCode(code):
            return .requestJSONEncodable(FriendCodeRequestDTO(code: code))
        }
    }

    // MARK: - Headers
    var headers: [String: String]? {
        HTTPHeader.json.value
    }
}
