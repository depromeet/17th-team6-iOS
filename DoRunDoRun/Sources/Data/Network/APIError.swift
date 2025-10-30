//
//  APIError.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/30/25.
//

import Foundation

/// 서버 응답 상태 코드 및 네트워크 오류를 통합 관리하는 에러 타입
enum APIError: Error {
    // MARK: - 4xx: 클라이언트 오류
    case badRequest              // 400
    case unauthorized            // 401
    case forbidden               // 403
    case notFound                // 404
    case conflict                // 409
    case unprocessableEntity     // 422
    case tooManyRequests         // 429

    // MARK: - 5xx: 서버 오류
    case internalServer          // 500
    case serviceUnavailable      // 503
    case gatewayTimeout          // 504

    // MARK: - 기타
    case networkError
    case decodingError
    case unknown
}

extension APIError {

    /// HTTP 상태 코드로부터 APIError 변환
    static func from(statusCode: Int) -> APIError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 409: return .conflict
        case 422: return .unprocessableEntity
        case 429: return .tooManyRequests
        case 500: return .internalServer
        case 503: return .serviceUnavailable
        case 504: return .gatewayTimeout
        default:  return .unknown
        }
    }

    /// 사용자에게 보여줄 기본 에러 메시지
    /// - Note:
    ///   `userMessage`는 **전역 공통 기본 문구**로 사용됩니다.
    ///   하지만 **Feature 단에서 상황에 맞는 메시지로 대체**해도 됩니다.
    ///   예를 들어 `.unprocessableEntity`의 경우
    ///   `인증번호가 올바르지 않습니다.`처럼 화면별로 맞춤 문구를 지정할 수 있습니다.
    var userMessage: String {
        switch self {
        // MARK: - 4xx
        case .badRequest:
            return "요청이 올바르지 않습니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .forbidden:
            return "접근 권한이 없습니다."
        case .notFound:
            return "요청한 정보를 찾을 수 없습니다."
        case .conflict:
            return "이미 존재하는 데이터입니다."
        case .unprocessableEntity:
            return "입력값을 처리할 수 없습니다."
        case .tooManyRequests:
            return "요청 횟수를 초과했습니다. 잠시 후 다시 시도해주세요."

        // MARK: - 5xx
        case .internalServer:
            return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .serviceUnavailable:
            return "현재 서버가 응답하지 않습니다. 잠시 후 다시 시도해주세요."
        case .gatewayTimeout:
            return "서버 응답이 지연되고 있습니다."

        // MARK: - 기타
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .decodingError:
            return "데이터를 불러오는 중 문제가 발생했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
