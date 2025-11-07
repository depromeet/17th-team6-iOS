//
//  UserAPI.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation
import Moya

enum UserAPI {
    case fetchProfile
    case updateProfile(request: UserProfileUpdateRequestDTO, profileImageData: Data?)
}

extension UserAPI: TargetType {
    var baseURL: URL { APIConfig.baseURL }

    var path: String {
        switch self {
        case .fetchProfile:
            return "/api/users/me/profile"
        case .updateProfile:
            return "/api/users/me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchProfile:
            return .get
        case .updateProfile:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .fetchProfile:
            return .requestPlain

        case let .updateProfile(request, profileImageData):
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
        }
    }

    var headers: [String : String]? {
        switch self {
        case .updateProfile:
            return HTTPHeader.multipart.value
        default:
            return HTTPHeader.json.value
        }
    }
}
