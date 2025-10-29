//
//  AuthSignupRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import Foundation

final class AuthSignupRepositoryImpl: AuthSignupRepository {
    private let service: AuthService

    init(service: AuthService = AuthServiceImpl()) {
        self.service = service
    }

    func signup(request: AuthSignupRequestDTO, profileImageData: Data?) async throws -> SignupResult {
        let dto = try await service.signup(request: request, profileImageData: profileImageData)
        return dto.data.toDomain()
    }
}
