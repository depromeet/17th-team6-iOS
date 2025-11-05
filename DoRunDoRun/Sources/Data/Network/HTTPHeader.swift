//
//  HTTPHeader.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation

/// HTTP 헤더 키 정의
enum HTTPHeaderKey: String {
    case contentType = "Content-Type"
    case accept = "Accept"
}

/// HTTP 헤더 값 정의
enum HTTPHeaderValue: String {
    case json = "application/json"
    case multipart = "multipart/form-data"
}

/// 자주 쓰는 헤더 조합 정의
enum HTTPHeader {
    case json
    case multipart
}

extension HTTPHeader {
    var value: [String: String] {
        switch self {
        case .json:
            return [
                HTTPHeaderKey.contentType.rawValue: HTTPHeaderValue.json.rawValue,
                HTTPHeaderKey.accept.rawValue: HTTPHeaderValue.json.rawValue
            ]
        case .multipart:
            return [
                HTTPHeaderKey.accept.rawValue: HTTPHeaderValue.json.rawValue
            ]
        }
    }
}
