//
//  TokenRefresher.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation
import Moya
import Alamofire

enum RefreshResult {
    case success
    case networkError    // 네트워크 오류 → 토큰 유지
    case serverRejected  // 서버 거부 → 토큰 삭제
}

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
    func tryRefresh() async -> RefreshResult {
        guard let refreshToken = TokenManager.shared.refreshToken, !refreshToken.isEmpty else {
            print("❌ [TokenRefresher] No refresh token found.")
            return .serverRejected
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

            return .success

        } catch let moyaError as MoyaError {
            print("❌ [TokenRefresher] Server rejected refresh:", moyaError)
            return .serverRejected
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ [TokenRefresher] Decoding error: dataCorrupted - \(context.debugDescription)")
            return .serverRejected
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ [TokenRefresher] Decoding error: key '\(key)' not found - \(context.debugDescription)")
            return .serverRejected
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ [TokenRefresher] Decoding error: value '\(value)' not found - \(context.debugDescription)")
            return .serverRejected
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ [TokenRefresher] Decoding error: type '\(type)' mismatch - \(context.debugDescription)")
            return .serverRejected
        } catch let urlError as URLError {
            print("❌ [TokenRefresher] Network error (URLError):", urlError)
            return .networkError
        } catch {
            print("❌ [TokenRefresher] Unknown error:", error)
            return .networkError
        }
    }

    // MARK: - Setter Helper (for actor-safe set)
    func setRefreshing(_ value: Bool) {
        isRefreshing = value
    }
}

extension TokenRefresher {
    static func isAccessTokenValid(_ token: String) -> Bool {
        guard let payload = decodeJWT(token),
              let exp = payload["exp"] as? TimeInterval else {
            return false
        }
        let expiration = Date(timeIntervalSince1970: exp)
        return expiration > Date()
    }

    private static func decodeJWT(_ token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }
        var base64 = String(segments[1])
        base64 = base64.replacingOccurrences(of: "-", with: "+")
                        .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return json
    }
}

