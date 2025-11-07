//
//  UserProfileRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation

final class UserProfileRepositoryImpl: UserProfileRepository {
    private let service: UserService

    init(service: UserService = UserServiceImpl()) {
        self.service = service
    }

    func fetchProfile() async throws -> UserProfile {
        let dto = try await service.fetchProfile()
        return dto.data.toDomain()
    }
}
