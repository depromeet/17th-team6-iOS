//
//  UserProfileUpdateRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

final class UserProfileUpdateRepositoryMock: UserProfileUpdateRepository {
    func updateProfile(
        request: UserProfileUpdateRequestDTO,
        profileImageData: Data?
    ) async throws -> String? {
        return "https://example.com/profile/updated_mock.jpg"
    }
}
