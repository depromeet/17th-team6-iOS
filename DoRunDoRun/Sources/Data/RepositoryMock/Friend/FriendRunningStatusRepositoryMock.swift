//
//  FriendRunningStatusRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation

/// 유저 및 친구 러닝 상태 Repository 프로토콜의 Mock 구현체
final class FriendRunningStatusRepositoryMock: FriendRunningStatusRepository {
    func fetchRunningStatuses(page: Int, size: Int) async throws -> [FriendRunningStatus] {
        let actualPage = max(page, 1)
        print("[Mock] \(actualPage)페이지 친구 러닝 상태 불러오기 성공")

        // 3페이지까지만 데이터 제공
        guard actualPage <= 3 else {
            return []
        }

        // 페이지·사이즈 기반 Mock 데이터 생성
        return (1...size).map { index in
            let id = (actualPage - 1) * size + index
            let isMe = id == 1 // 첫 번째 데이터만 ‘나’로 설정

            return FriendRunningStatus(
                id: id,
                nickname: isMe ? "나(\(id))" : "친구 \(id)",
                isMe: isMe,
                profileImageURL: nil,
                latestRanAt: Date().addingTimeInterval(Double(-index * 3600 * actualPage)), // 시간차
                latestCheeredAt: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...5), to: .now),
                distance: Double.random(in: 3000...10000),
                latitude: 37.4 + Double.random(in: 0...0.2),
                longitude: 126.8 + Double.random(in: 0...0.2),
                address: ["서울", "광명", "인천", "부천"].randomElement()
            )
        }
    }
}
