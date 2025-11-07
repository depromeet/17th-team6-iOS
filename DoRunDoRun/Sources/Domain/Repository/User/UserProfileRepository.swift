//
//  UserProfileRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation

protocol UserProfileRepository: AnyObject {
    func fetchProfile() async throws -> UserProfile
}
