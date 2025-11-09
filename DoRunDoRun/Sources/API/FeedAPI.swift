//
//  FeedAPI.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/31/25.
//

import Moya
import Foundation

enum FeedAPI {
    case feedList(currentDate: String, userId: Int?, page: Int, size: Int)
}


extension FeedAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://api.dorundorun.store")!
    }

    var path: String {
        switch self {
            case .feedList:
                "/api/selfie/feeds"
        }
    }

    var method: Moya.Method {
        switch self {
            case .feedList:
                .get
        }
    }

    var task: Moya.Task {
        switch self {
            case let .feedList(currentDate, userId, page, size):
                return .requestParameters(parameters: [
                    "currentDate": currentDate,
                    "userId": userId,
                    "page": page,
                    "size": size
                ], encoding: JSONEncoding())
        }
    }

    var headers: [String : String]? {
        switch self {
            case .feedList:
                nil
        }
    }
}

extension FeedAPI {
    var sampleData: Data {
        switch self {
            case .feedList:
                """
                {
                  "status": "CONTINUE",
                  "message": "string",
                  "timestamp": "2025-11-02T04:57:33.689Z",
                  "data": {
                    "userSummary": {
                      "name": "닉네임",
                      "profileImageUrl": "https://example.com/profile.jpg",
                      "friendCount": 7,
                      "totalDistance": 400000,
                      "selfieCount": 120
                    },
                    "feeds": {
                      "contents": [
                        {
                          "feedId": 1,
                          "date": "2025-09-20",
                          "userName": "닉네임",
                          "profileImageUrl": "https://example.com/profile.jpg",
                          "isMyFeed": true,
                          "selfieTime": "2025-11-02T04:57:33.689Z",
                          "totalDistance": 5100,
                          "totalRunTime": 2647,
                          "averagePace": 360,
                          "cadence": 144,
                          "imageUrl": "https://example.com/images/selfie123.jpg",
                          "reactions": [
                            {
                              "emojiType": "FIRE",
                              "totalCount": 5,
                              "isReactedByMe": true,
                              "users": [
                                {
                                  "userId": 1,
                                  "nickname": "러너123",
                                  "profileImageUrl": "https://cdn.example.com/profiles/user123.jpg",
                                  "isMe": true,
                                  "reactedAt": "2025-11-02T04:57:33.689Z"
                                }
                              ]
                            }
                          ]
                        }
                      ],
                      "meta": {
                        "page": 0,
                        "size": 0,
                        "totalElements": 0,
                        "totalPages": 0,
                        "first": true,
                        "last": true,
                        "hasNext": true,
                        "hasPrevious": true
                      }
                    }
                  }
                }
                """.data(using: .utf8)!
        }
    }
}
