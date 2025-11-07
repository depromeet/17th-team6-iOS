//
//  UserProfileRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation

final class UserProfileRepositoryMock: UserProfileRepository {
    func fetchProfile() async throws -> UserProfile {
        UserProfile(
            id: 1,
            nickname: "테스트 유저",
            profileImageURL: "https://example.com/profile/test.jpg",
            code: "TEST123",
            phoneNumber: "010-1234-5678",
            createdAt: "2025-11-07T14:53:52.077Z"
        )
    }
}
