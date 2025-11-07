//
//  UserProfileUpdateUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

protocol UserProfileUpdateUseCaseProtocol {
    func execute(request: UserProfileUpdateRequestDTO, profileImageData: Data?) async throws -> String?
}

final class UserProfileUpdateUseCase: UserProfileUpdateUseCaseProtocol {
    private let repository: UserProfileUpdateRepository

    init(repository: UserProfileUpdateRepository = UserProfileUpdateRepositoryImpl()) {
        self.repository = repository
    }

    func execute(request: UserProfileUpdateRequestDTO, profileImageData: Data?) async throws -> String? {
        try await repository.updateProfile(request: request, profileImageData: profileImageData)
    }
}
