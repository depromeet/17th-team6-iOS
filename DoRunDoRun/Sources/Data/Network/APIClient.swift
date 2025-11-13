//
//  APIClient.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

import Alamofire
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
        // MARK: - 공통 플러그인 (로깅 등)
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]

        // MARK: - TokenInterceptor 연결된 Session 생성
        let session = Session(interceptor: TokenInterceptor())

        // MARK: - Provider 초기화
        if stub {
            provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            provider = MoyaProvider<MultiTarget>(
                session: session,
                plugins: plugins
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

                    // 1) MoyaError에서 Response 추출
                    if let response = error.response {
                        let status = response.statusCode
                        
                        // statusCode 기반으로 APIError 매핑 (가장 중요)
                        continuation.resume(throwing: APIError.from(statusCode: status))
                        return
                    }

                    // 2) 네트워크 오류 판단
                    if case let .underlying(afError, _) = error,
                       let afError = afError as? AFError,
                       case let .sessionTaskFailed(innerError) = afError,
                       let nsError = innerError as NSError? {

                        if nsError.domain == NSURLErrorDomain {
                            switch nsError.code {
                            case NSURLErrorNotConnectedToInternet,
                                 NSURLErrorNetworkConnectionLost,
                                 NSURLErrorCannotFindHost,
                                 NSURLErrorCannotConnectToHost,
                                 NSURLErrorTimedOut:
                                continuation.resume(throwing: APIError.networkError)
                                return
                            default:
                                break
                            }
                        }
                    }

                    // 3) 그 외의 경우 unknown
                    continuation.resume(throwing: APIError.unknown)
                }
            }
        }
    }
}
