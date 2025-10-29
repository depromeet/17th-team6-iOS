//
//  AuthAPI.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/27/25.
//

import Foundation
import Moya

enum AuthAPI {
    case sendSMS(phoneNumber: String)
    case verifySMS(phoneNumber: String, verificationCode: String)
    case signup(request: AuthSignupRequestDTO, profileImageData: Data?)
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨 BASE_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .sendSMS:
            return "/api/auth/sms/send"
        case .verifySMS:
            return "/api/auth/sms/verify"
        case .signup:
            return "/api/auth/signup"
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case let .sendSMS(phoneNumber):
            return .requestParameters(
                parameters: ["phoneNumber": phoneNumber],
                encoding: JSONEncoding.default
            )

        case let .verifySMS(phoneNumber, verificationCode):
            return .requestParameters(
                parameters: [
                    "phoneNumber": phoneNumber,
                    "verificationCode": verificationCode
                ],
                encoding: JSONEncoding.default
            )

        case let .signup(request, profileImageData):
            // 1. JSON 데이터를 data 필드로 감싸서 multipart로 인코딩
            var multipartData: [MultipartFormData] = []

            // JSON 인코딩된 request
            if let jsonData = try? JSONEncoder().encode(request) {
                multipartData.append(
                    MultipartFormData(
                        provider: .data(jsonData),
                        name: "data",
                        mimeType: "application/json"
                    )
                )
            }

            // 2. 프로필 이미지가 있다면 추가
            if let imageData = profileImageData {
                multipartData.append(
                    MultipartFormData(
                        provider: .data(imageData),
                        name: "profileImage",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }

            return .uploadMultipart(multipartData)
        }
    }

    var headers: [String: String]? {
        switch self {
        case .signup:
            // multipart 업로드 시엔 JSON이 아니라 multipart/form-data 헤더를 자동으로 설정하므로 Content-Type 제외
            return ["Accept": "application/json"]
        default:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
    }
}
