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

        // /api/auth/ 하위 요청에는 Authorization 헤더 추가하지 않음
        if let urlString = request.url?.absoluteString,
           !urlString.contains("/api/auth/"),
           let accessToken = TokenManager.shared.accessToken {
            request.headers.add(.authorization(bearerToken: accessToken))
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
        // 401이 아닌 경우 재시도 X
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }

        Task {
            let refresher = TokenRefresher.shared

            // 이미 refresh 중이라면 → completion을 대기열에 추가
            if await refresher.isRefreshing {
                await refresher.addPending(completion)
                return
            }

            // refresh 시도 시작
            await refresher.setRefreshing(true)
            let success = await refresher.tryRefresh()
            await refresher.setRefreshing(false)

            // refresh 성공 → 모든 대기 요청 재시도
            if success {
                await refresher.flushPending(retry: true)
                completion(.retry)
            } else {
                await refresher.flushPending(retry: false)
                completion(.doNotRetry)

                // 로그아웃 이벤트 발생 (옵션)
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("sessionExpired")
}
