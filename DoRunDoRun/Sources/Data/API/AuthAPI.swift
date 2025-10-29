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
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
    }
}
