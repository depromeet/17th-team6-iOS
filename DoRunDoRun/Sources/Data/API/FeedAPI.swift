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
}

extension FeedAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .getFeedsByDate:
            return "/api/selfie/feeds"
        }
    }

    var method: Moya.Method {
        return .get
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
        }
    }

    var headers: [String: String]? {
        HTTPHeader.json.value
    }
}
