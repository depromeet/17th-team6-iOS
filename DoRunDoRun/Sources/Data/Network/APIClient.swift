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
        // 공통 플러그인 리스트 정의
        var plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        
        // accessToken이 존재하면 AuthPlugin을 함께 등록
        if TokenManager.shared.accessToken != nil {
            plugins.append(AuthPlugin())
        }
        
        if stub {
            provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            provider = MoyaProvider<MultiTarget>(plugins: plugins)
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
                        // HTTP 상태 코드 확인
                        if (200..<300).contains(response.statusCode) {
                            let decoded = try JSONDecoder().decode(T.self, from: response.data)
                            continuation.resume(returning: decoded)
                        } else {
                            // 여기서 statusCode 기반으로 APIError 변환
                            let apiError = APIError.from(statusCode: response.statusCode)
                            continuation.resume(throwing: apiError)
                        }
                    } catch {
                        // JSON 디코딩 에러
                        continuation.resume(throwing: APIError.decodingError)
                    }
                    
                case let .failure(error):
                    // 네트워크 오류 처리
                    switch error {
                    case .underlying(let nsError as NSError, _)
                        where nsError.domain == NSURLErrorDomain:
                        continuation.resume(throwing: APIError.networkError)
                    default:
                        continuation.resume(throwing: APIError.unknown)
                    }
                }
            }
        }
    }
}
