//
//  AuthPlugin.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation
import Moya

final class AuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue("Bearer \(TokenManager.shared.accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
