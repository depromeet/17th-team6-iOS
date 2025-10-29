//
//  AuthSignupRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import Foundation

protocol AuthSignupRepository {
    func signup(request: AuthSignupRequestDTO, profileImageData: Data?) async throws -> SignupResult
}
