//
//  APIClient.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Alamofire

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpointProtocol, responseType: T.Type) async throws -> T
}

/// Alamofire 기반 API 호출 담당 클래스
final class APIClient: APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpointProtocol, responseType: T.Type) async throws -> T {
        let url = "\(NetworkConstants.baseURL)\(endpoint.path)"

        return try await AF.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            headers: NetworkConstants.defaultHeaders
        )
        .validate()
        .serializingDecodable(responseType)
        .value
    }
}
