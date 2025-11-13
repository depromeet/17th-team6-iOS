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
    case getFeedById(feedId: Int)
    case postReaction(feedId: Int, emojiType: String)
    case createFeed(data: SelfieFeedCreateRequestDTO, selfieImage: Data?)
    case updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?)
    case deleteFeed(feedId: Int)
    case getWeeklySelfieCount(startDate: String, endDate: String)
    case getSelfieUsersByDate(date: String)
    case checkUploadable(runSessionId: Int)
}

extension FeedAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .getFeedsByDate, .createFeed:
            return "/api/selfie/feeds"
        case let .getFeedById(feedId):
            return "/api/selfie/feeds/\(feedId)"
        case .postReaction:
            return "/api/selfie/feeds/reaction"
        case let .updateFeed(feedId, _, _),
             let .deleteFeed(feedId):
            return "/api/selfie/feeds/\(feedId)"
        case .getWeeklySelfieCount:
            return "/api/selfie/week"
        case .getSelfieUsersByDate:
            return "/api/selfie/users"
        case .checkUploadable:
            return "/api/selfie/uploadable"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getFeedsByDate: return .get
        case .getFeedById: return .get
        case .postReaction: return .post
        case .createFeed: return .post
        case .updateFeed: return .put
        case .deleteFeed: return .delete
        case .getWeeklySelfieCount: return .get
        case .getSelfieUsersByDate: return .get
        case .checkUploadable: return .get
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
            
        case .getFeedById: return .requestPlain

        case let .postReaction(feedId, emojiType):
            let body = SelfieFeedReactionRequestDTO(feedId: feedId, emojiType: emojiType)
            return .requestJSONEncodable(body)
            
        case let .createFeed(data, selfieImage):
            var multipartData: [MultipartFormData] = []

            if let jsonData = try? JSONEncoder().encode(data) {
                print("📤 [Multipart JSON Body] \n", String(data: jsonData, encoding: .utf8) ?? "nil")
                multipartData.append(
                    MultipartFormData(
                        provider: .data(jsonData),
                        name: "data",
                        fileName: "data.json",
                        mimeType: "application/json"
                    )
                )
            }

            if let selfieImage = selfieImage {
                multipartData.append(
                    MultipartFormData(
                        provider: .data(selfieImage),
                        name: "selfieImage",
                        fileName: "image.jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }

            return .uploadMultipart(multipartData)

        case let .updateFeed(_, data, selfieImage):
            var multipart: [MultipartFormData] = []

            if let jsonData = try? JSONEncoder().encode(data) {
                multipart.append(
                    MultipartFormData(
                        provider: .data(jsonData),
                        name: "data",
                        fileName: "data.json",
                        mimeType: "application/json"
                    )
                )
            }

            if let selfieImage = selfieImage {
                multipart.append(
                    MultipartFormData(
                        provider: .data(selfieImage),
                        name: "selfieImage",
                        fileName: "image.jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }

            return .uploadMultipart(multipart)
            
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
            
        case let .checkUploadable(runSessionId):
            return .requestParameters(
                parameters: ["runSessionId": runSessionId],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        switch self {
        case .createFeed, .updateFeed:
            return HTTPHeader.multipart.value  
        default:
            return HTTPHeader.json.value
        }
    }

    var validationType: ValidationType { .successCodes }
}
