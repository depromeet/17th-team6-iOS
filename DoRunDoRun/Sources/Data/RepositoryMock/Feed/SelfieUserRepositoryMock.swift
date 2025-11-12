//
//  SelfieUserRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation

final class SelfieUserRepositoryMock: SelfieUserRepository {
    func fetchUsersByDate(date: String) async throws -> [SelfieUserResult] {
        print("[Mock] 인증 사용자 목록 조회 성공 (\(date))")

        return [
            SelfieUserResult(
                id: 1,
                name: "비락식혜",
                profileImageUrl: "https://picsum.photos/200",
                postingTime: "2025-11-10T14:30:00Z",
                isMe: true
            ),
            SelfieUserResult(
                id: 2,
                name: "불닭마요",
                profileImageUrl: "https://picsum.photos/201",
                postingTime: "2025-11-10T14:45:00Z",
                isMe: false
            ),
            SelfieUserResult(
                id: 3,
                name: "참깨라면",
                profileImageUrl: "https://picsum.photos/202",
                postingTime: "2025-11-10T15:10:00Z",
                isMe: false
            )
        ]
    }
}
