//
//  TokenInterceptor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation
import Alamofire

final class TokenInterceptor: RequestInterceptor {
    private let lock = NSLock()

    // MARK: - 요청 전 (AccessToken 헤더 추가)
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest

        #if DEBUG
        if let urlString = request.url?.absoluteString {
            print("🟦 [TokenInterceptor.adapt] 요청 URL: \(urlString)")
        }
        #endif

        if let urlString = request.url?.absoluteString {
            // 인증이 필요 없는 auth 요청만 예외 처리
            let authExemptEndpoints = [
                "/api/auth/refresh",
                "/api/auth/send",
                "/api/auth/verify",
                "/api/auth/signup"
            ]
            
            if authExemptEndpoints.contains(where: { urlString.contains($0) }) {
                #if DEBUG
                print("🟨 [TokenInterceptor.adapt] 인증 불필요 API → Authorization 헤더 추가 안 함")
                #endif
            } else if let accessToken = TokenManager.shared.accessToken {
                request.headers.add(.authorization(bearerToken: accessToken))
                #if DEBUG
                print("🟩 [TokenInterceptor.adapt] AccessToken 추가 완료: \(accessToken.prefix(10))...")
                #endif
            } else {
                #if DEBUG
                print("🟥 [TokenInterceptor.adapt] AccessToken 없음 → 헤더 추가 안 함")
                #endif
            }
        }

        completion(.success(request))
    }

    // MARK: - 응답 시 (401 → refresh 후 재시도)
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        #if DEBUG
        print("\n🟧 [TokenInterceptor.retry] 호출됨")
        if let response = request.task?.response as? HTTPURLResponse {
            print("🔸 [TokenInterceptor.retry] statusCode = \(response.statusCode)")
        } else {
            print("🟥 [TokenInterceptor.retry] response 없음 (request.task?.response == nil)")
        }
        #endif

        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            #if DEBUG
            print("🟨 [TokenInterceptor.retry] 401 아님 → 재시도 안 함")
            #endif
            completion(.doNotRetry)
            return
        }

        #if DEBUG
        print("🟥 [TokenInterceptor.retry] 401 감지 → refresh 시도 예정")
        #endif

        Task {
            let refresher = TokenRefresher.shared

            if await refresher.isRefreshing {
                #if DEBUG
                print("🔄 [TokenInterceptor.retry] 이미 refresh 중 → 대기열에 추가")
                #endif
                await refresher.addPending(completion)
                return
            }

            #if DEBUG
            print("🟢 [TokenInterceptor.retry] refresh 시작")
            #endif
            await refresher.setRefreshing(true)

            let success = await refresher.tryRefresh()

            #if DEBUG
            print("🟩 [TokenInterceptor.retry] refresh 결과: \(success ? "성공 ✅" : "실패 ❌")")
            #endif

            await refresher.setRefreshing(false)

            if success {
                #if DEBUG
                print("🟦 [TokenInterceptor.retry] 모든 pending 요청 재시도")
                #endif
                await refresher.flushPending(retry: true)
                completion(.retry)
            } else {
                #if DEBUG
                print("🟥 [TokenInterceptor.retry] refresh 실패 → 세션 만료 처리")
                #endif
                await refresher.flushPending(retry: false)
                completion(.doNotRetry)
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("sessionExpired")
}
