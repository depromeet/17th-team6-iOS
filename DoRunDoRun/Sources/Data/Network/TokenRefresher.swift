//
//  TokenRefresher.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation
import Moya
import Alamofire

/// 여러 요청이 동시에 401을 받아도 한 번만 refresh 하도록 방지
actor TokenRefresher {
    static let shared = TokenRefresher()
    private(set) var isRefreshing = false
    private var pendingCompletions: [(RetryResult) -> Void] = []   // Alamofire.RetryResult 사용

    // MARK: - Pending
    func addPending(_ completion: @escaping (RetryResult) -> Void) {
        pendingCompletions.append(completion)
    }

    func flushPending(retry: Bool) {
        pendingCompletions.forEach { $0(retry ? .retry : .doNotRetry) }
        pendingCompletions.removeAll()
    }

    // MARK: - Refresh Logic
    func tryRefresh() async -> Bool {
        guard let refreshToken = TokenManager.shared.refreshToken, !refreshToken.isEmpty else {
            print("No refresh token found.")
            return false
        }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            // MoyaProvider<AuthAPI>를 사용해 refresh 요청
            let provider = MoyaProvider<AuthAPI>()
            let response = try await withCheckedThrowingContinuation { continuation in
                provider.request(.refreshToken(refreshToken: refreshToken)) { result in
                    switch result {
                    case let .success(res):
                        continuation.resume(returning: res)
                    case let .failure(err):
                        continuation.resume(throwing: err)
                    }
                }
            }

            // 응답 디코딩
            let decoded = try JSONDecoder().decode(AuthRefreshResponseDTO.self, from: response.data)
            let newAccess = decoded.data.accessToken
            let newRefresh = decoded.data.refreshToken

            // 토큰 저장
            TokenManager.shared.accessToken = newAccess
            TokenManager.shared.refreshToken = newRefresh

            print("Token refreshed successfully.")
            return true

        } catch {
            print("Token refresh failed: \(error)")
            return false
        }
    }

    // MARK: - Setter Helper (for actor-safe set)
    func setRefreshing(_ value: Bool) {
        isRefreshing = value
    }
}
