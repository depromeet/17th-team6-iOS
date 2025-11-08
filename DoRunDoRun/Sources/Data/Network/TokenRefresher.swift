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
    private var pendingCompletions: [(RetryResult) -> Void] = []

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
            print("❌ [TokenRefresher] No refresh token found.")
            return false
        }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            print("🔄 [TokenRefresher] Start refresh with token: \(refreshToken.prefix(10))...")

            // refresh 요청용 provider (인터셉터 없이)
            let session = Session() // interceptor 없는 세션
            let provider = MoyaProvider<AuthAPI>(session: session, plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))])

            // 서버 요청
            let response = try await withCheckedThrowingContinuation { continuation in
                provider.request(.refreshToken(refreshToken: refreshToken)) { result in
                    switch result {
                    case let .success(res):
                        print("✅ [TokenRefresher] Server responded with statusCode: \(res.statusCode)")
                        print("📦 [TokenRefresher] Response data:", String(data: res.data, encoding: .utf8) ?? "nil")
                        continuation.resume(returning: res)
                    case let .failure(err):
                        print("❌ [TokenRefresher] Network error:", err)
                        continuation.resume(throwing: err)
                    }
                }
            }

            // 디코딩 시도
            let decoded = try JSONDecoder().decode(AuthRefreshResponseDTO.self, from: response.data)
            print("✅ [TokenRefresher] Decoded refresh response successfully")

            // 토큰 저장
            TokenManager.shared.accessToken = decoded.data.accessToken
            TokenManager.shared.refreshToken = decoded.data.refreshToken
            print("🔑 [TokenRefresher] Token updated successfully")

            return true

        } catch let DecodingError.dataCorrupted(context) {
            print("❌ [TokenRefresher] Decoding error: dataCorrupted - \(context.debugDescription)")
            return false
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ [TokenRefresher] Decoding error: key '\(key)' not found - \(context.debugDescription)")
            return false
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ [TokenRefresher] Decoding error: value '\(value)' not found - \(context.debugDescription)")
            return false
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ [TokenRefresher] Decoding error: type '\(type)' mismatch - \(context.debugDescription)")
            return false
        } catch {
            print("❌ [TokenRefresher] Unknown error:", error)
            return false
        }
    }

    // MARK: - Setter Helper (for actor-safe set)
    func setRefreshing(_ value: Bool) {
        isRefreshing = value
    }
}
