//
//  FeedAPI.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation
import Moya

enum FeedAPI {
    case getFeedsByDate(currentDate: String?, userId: Int?, page: Int, size: Int)
    case postReaction(feedId: Int, emojiType: String)
}

extension FeedAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .getFeedsByDate:
            return "/api/selfie/feeds"
        case .postReaction:
            return "/api/selfie/feeds/reaction"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getFeedsByDate:
            return .get
        case .postReaction:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .getFeedsByDate(currentDate, userId, page, size):
            var params: [String: Any] = [
                "page": page,
                "size": size
            ]
            if let currentDate = currentDate { params["currentDate"] = currentDate }
            if let userId = userId { params["userId"] = userId }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case let .postReaction(feedId, emojiType):
            let body = SelfieFeedReactionRequestDTO(feedId: feedId, emojiType: emojiType)
            return .requestJSONEncodable(body)
        }
    }

    var headers: [String: String]? {
        HTTPHeader.json.value
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
