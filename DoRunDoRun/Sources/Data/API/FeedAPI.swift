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
    case updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?)
    case deleteFeed(feedId: Int)
}

extension FeedAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .getFeedsByDate:
            return "/api/selfie/feeds"
        case .postReaction:
            return "/api/selfie/feeds/reaction"
        case let .updateFeed(feedId, _, _),
             let .deleteFeed(feedId):
            return "/api/selfie/feeds/\(feedId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getFeedsByDate: return .get
        case .postReaction: return .post
        case .updateFeed: return .put
        case .deleteFeed: return .delete
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

        case let .updateFeed(_, data, selfieImage):
            var formData: [MultipartFormData] = []

            // JSON 데이터 인코딩
            if let jsonData = try? JSONEncoder().encode(data) {
                formData.append(.init(provider: .data(jsonData),
                                      name: "data",
                                      mimeType: "application/json"))
            }

            // 이미지 파일 추가 (선택)
            if let selfieImage = selfieImage {
                formData.append(.init(provider: .data(selfieImage),
                                      name: "selfieImage",
                                      fileName: "image.jpg",
                                      mimeType: "image/jpeg"))
            }

            return .uploadMultipart(formData)


        case .deleteFeed:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .updateFeed:
            return HTTPHeader.multipart.value
        default:
            return HTTPHeader.json.value
        }
    }

    var validationType: ValidationType { .successCodes }
}
