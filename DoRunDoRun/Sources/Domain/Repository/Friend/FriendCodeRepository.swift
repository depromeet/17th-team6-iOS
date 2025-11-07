//
//  FriendCodeRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

protocol FriendCodeRepository {
    func addFriendByCode(_ code: String) async throws -> FriendCode
}
