//
//  RunningAPI.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import Foundation
import Moya

enum RunningAPI {
    case searchRunnign(isSelfied: Bool, startDateTime: String?, endDateTime: String?)
}

extension RunningAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://api.dorundorun.store")!
    }

    var path: String {
        switch self {
            case .searchRunnign:
                "/api/runs/sessions"
        }
    }

    var method: Moya.Method {
        switch self {
            case .searchRunnign:
                .get
        }
    }

    var task: Moya.Task {
        switch self {
            case let .searchRunnign(isSelfied, startDateTime, endDateTime):
                return .requestParameters(parameters: [
                    "isSelfied": isSelfied,
                    "startDateTime": startDateTime,
                    "endDateTime": endDateTime
                ], encoding: JSONEncoding())
        }
    }

    var headers: [String : String]? {
        switch self {
            case .searchRunnign:
                nil
        }
    }
}


extension RunningAPI {
    var sampleData: Data {
        switch self {
            case .searchRunnign:
                """
                {
                  "status": "CONTINUE",
                  "message": "string",
                  "timestamp": "2025-11-09T04:17:01.856Z",
                  "data": [
                    {
                      "runSessionId": 1,
                      "createdAt": "2024-01-15T09:00:00Z",
                      "updatedAt": "2024-01-15T10:30:00Z",
                      "finishedAt": "2024-01-15T10:30:00Z",
                      "distanceTotal": 5000,
                      "durationTotal": 1800,
                      "paceAvg": 360,
                      "cadenceAvg": 170,
                      "isSelfied": false,
                      "mapImage": "https://example.com/map.jpg"
                    }
                  ]
                }
                """.data(using: .utf8)!
        }
    }
}
