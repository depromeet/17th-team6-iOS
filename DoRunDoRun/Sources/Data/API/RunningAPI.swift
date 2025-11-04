//
//  RunningAPI.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation
import Moya

enum RunningAPI {
    case start
    case saveSegments(sessionId: Int, request: RunningSegmentRequestDTO)
    case complete(sessionId: Int, data: RunningCompleteRequestDTO, mapImage: Data?)
    case sessions(isSelfied: Bool?, startDateTime: String?)
    case sessionDetail(sessionId: Int)
}

extension RunningAPI: TargetType {
    var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨 BASE_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .start:
            return "/api/runs/sessions/start"
        case .saveSegments(let sessionId, _):
            return "/api/runs/sessions/\(sessionId)/segments"
        case .complete(let sessionId, _, _):
            return "/api/runs/sessions/\(sessionId)/complete"
        case .sessions:
            return "/api/runs/sessions"
        case .sessionDetail(let sessionId):
            return "/api/runs/sessions/\(sessionId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .start, .saveSegments, .complete:
            return .post
        case .sessions, .sessionDetail:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .start:
            // Request body 없음
            return .requestPlain

        case let .saveSegments(_, request):
            // JSON body로 전송
            return .requestJSONEncodable(request)

        case let .complete(_, data, mapImage):
            // multipart/form-data 전송
            var multipartData: [MultipartFormData] = []

            // 1. JSON 데이터를 data 필드로 전송
            if let jsonData = try? JSONEncoder().encode(data) {
                multipartData.append(
                    MultipartFormData(
                        provider: .data(jsonData),
                        name: "data",
                        mimeType: "application/json"
                    )
                )
            }

            // 2. 지도 이미지가 있다면 추가
            if let imageData = mapImage {
                multipartData.append(
                    MultipartFormData(
                        provider: .data(imageData),
                        name: "mapImage",
                        fileName: "map.jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }

            return .uploadMultipart(multipartData)

        case let .sessions(isSelfied, startDateTime):
            // Query parameters로 전송
            var parameters: [String: Any] = [:]
            if let isSelfied = isSelfied {
                parameters["isSelfied"] = isSelfied
            }
            if let startDateTime = startDateTime {
                parameters["startDateTime"] = startDateTime
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )

        case .sessionDetail:
            // Path parameter만 사용
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        // TODO: 나중에 header 관련 수정 필요
        var baseHeaders: [String: String] = [
            "Authorization": "Bearer 1"
        ]

        switch self {
        case .complete:
            // multipart 업로드 시엔 Content-Type 자동 설정
            baseHeaders["Accept"] = "application/json"
        default:
            baseHeaders["Content-Type"] = "application/json"
            baseHeaders["Accept"] = "application/json"
        }

        return baseHeaders
    }
}
