//
//  UserAPI.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation
import Moya

enum UserAPI {
    case fetchProfile
}

extension UserAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .fetchProfile:
            return "/api/users/me/profile"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchProfile:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .fetchProfile:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        HTTPHeader.json.value
    }
}
