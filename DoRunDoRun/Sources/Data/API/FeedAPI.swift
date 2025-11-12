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
    case createFeed(data: SelfieFeedCreateRequestDTO, selfieImage: Data?)
    case updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?)
    case deleteFeed(feedId: Int)
    case getWeeklySelfieCount(startDate: String, endDate: String)
    case getSelfieUsersByDate(date: String)
}

extension FeedAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .getFeedsByDate, .createFeed:
            return "/api/selfie/feeds"
        case .postReaction:
            return "/api/selfie/feeds/reaction"
        case let .updateFeed(feedId, _, _),
             let .deleteFeed(feedId):
            return "/api/selfie/feeds/\(feedId)"
        case .getWeeklySelfieCount:
            return "/api/selfie/week"
        case .getSelfieUsersByDate:
            return "/api/selfie/users"

        }
    }

    var method: Moya.Method {
        switch self {
        case .getFeedsByDate: return .get
        case .postReaction: return .post
        case .createFeed: return .post
        case .updateFeed: return .put
        case .deleteFeed: return .delete
        case .getWeeklySelfieCount: return .get
        case .getSelfieUsersByDate: return .get
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
            
        case let .createFeed(data, selfieImage):
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
            
        case let .getWeeklySelfieCount(startDate, endDate):
            return .requestParameters(
                parameters: ["startDate": startDate, "endDate": endDate],
                encoding: URLEncoding.queryString
            )
            
        case let .getSelfieUsersByDate(date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
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
