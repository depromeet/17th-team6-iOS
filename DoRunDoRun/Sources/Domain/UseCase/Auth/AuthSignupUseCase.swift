//
//  AuthSignupUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import UIKit

protocol AuthSignupUseCaseProtocol {
    func execute(
        phoneNumber: String,
        nickname: String,
        marketingConsentAt: Date?,
        locationConsentAt: Date,
        personalConsentAt: Date,
        deviceToken: String,
        profileImage: UIImage?
    ) async throws -> SignupResult
}

final class AuthSignupUseCase: AuthSignupUseCaseProtocol {
    private let repository: AuthSignupRepository

    init(repository: AuthSignupRepository) {
        self.repository = repository
    }

    func execute(
        phoneNumber: String,
        nickname: String,
        marketingConsentAt: Date?,
        locationConsentAt: Date,
        personalConsentAt: Date,
        deviceToken: String,
        profileImage: UIImage?
    ) async throws -> SignupResult {
        let formatter = ISO8601DateFormatter()

        let consent = ConsentDTO(
            marketingConsentAt: marketingConsentAt.map { formatter.string(from: $0) },
            locationConsentAt: formatter.string(from: locationConsentAt),
            personalConsentAt: formatter.string(from: personalConsentAt)
        )

        let request = AuthSignupRequestDTO(
            phoneNumber: phoneNumber,
            nickname: nickname,
            consent: consent,
            deviceToken: deviceToken
        )

        let data = profileImage?.jpegData(compressionQuality: 0.8)
        return try await repository.signup(request: request, profileImageData: data)
    }
}
