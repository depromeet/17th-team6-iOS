//
//  UserProfileUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation

protocol UserProfileUseCaseProtocol {
    func execute() async throws -> UserProfile
}

final class UserProfileUseCase: UserProfileUseCaseProtocol {
    private let repository: UserProfileRepository

    init(repository: UserProfileRepository = UserProfileRepositoryImpl()) {
        self.repository = repository
    }

    func execute() async throws -> UserProfile {
        try await repository.fetchProfile()
    }
}
