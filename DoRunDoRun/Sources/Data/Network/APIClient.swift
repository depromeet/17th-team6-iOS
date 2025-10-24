//
//  APIClient.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

import Moya

protocol APIClientProtocol {
    func request<T: Decodable, Target: TargetType>(
        _ target: Target,
        responseType: T.Type
    ) async throws -> T
}

/// Moya 기반 API 호출 담당 클래스
final class APIClient: APIClientProtocol {
    private let provider: MoyaProvider<MultiTarget>

    init(stub: Bool = false) {
        if stub {
            provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            provider = MoyaProvider<MultiTarget>(
                plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
            )
        }
    }

    func request<T: Decodable, Target: TargetType>(
        _ target: Target,
        responseType: T.Type
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                switch result {
                case let .success(response):
                    do {
                        let filtered = try response.filterSuccessfulStatusCodes()
                        let decoded = try JSONDecoder().decode(T.self, from: filtered.data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
