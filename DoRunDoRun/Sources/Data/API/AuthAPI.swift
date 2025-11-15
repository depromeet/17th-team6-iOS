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
    case logout
    case withdraw
    case refreshToken(refreshToken: String)
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
        case .logout:
            return "/api/auth/logout"
        case .withdraw:
            return "/api/auth/withdraw"
        case .refreshToken:
            return "/api/auth/refresh"
        }
    }

    var method: Moya.Method {
        switch self {
        case .logout, .sendSMS, .verifySMS, .signup, .refreshToken:
            return .post
        case .withdraw:
            return .delete
        }
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
            var multipartData: [MultipartFormData] = []

            if let jsonData = try? JSONEncoder().encode(request) {
                multipartData.append(
                    MultipartFormData(
                        provider: .data(jsonData),
                        name: "data",
                        mimeType: "application/json"
                    )
                )
            }

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

        case .logout, .withdraw:
            return .requestPlain
            
        case let .refreshToken(refreshToken):
            return .requestParameters(
                parameters: ["refreshToken": refreshToken],
                encoding: JSONEncoding.default
            )
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
    
    var validationType: ValidationType {
        return .successCodes
    }
}
