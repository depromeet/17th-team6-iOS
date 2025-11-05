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
    var baseURL: URL { APIConfig.baseURL }

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
            // multipart/form-data 업로드 시 Content-Type은 자동 지정됨
            return HTTPHeader.multipart.value
        default:
            return HTTPHeader.json.value
        }
    }
}
