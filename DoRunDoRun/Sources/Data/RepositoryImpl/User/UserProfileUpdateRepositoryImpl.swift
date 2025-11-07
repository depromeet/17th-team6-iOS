//
//  UserProfileUpdateRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

final class UserProfileUpdateRepositoryImpl: UserProfileUpdateRepository {
    private let service: UserService

    init(service: UserService = UserServiceImpl()) {
        self.service = service
    }

    func updateProfile(
        request: UserProfileUpdateRequestDTO,
        profileImageData: Data?
    ) async throws -> String? {
        let dto = try await service.updateProfile(
            request: request,
            profileImageData: profileImageData
        )
        return dto.data.profileImageUrl
    }
}
