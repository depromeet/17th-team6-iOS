//
//  SelfieUserRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

protocol SelfieUserRepository {
    func fetchUsersByDate(date: String) async throws -> [SelfieUserResult]
}
