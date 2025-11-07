//
//  UserProfileUpdateRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation

protocol UserProfileUpdateRepository: AnyObject {
    func updateProfile(
        request: UserProfileUpdateRequestDTO,
        profileImageData: Data?
    ) async throws -> String?
}
