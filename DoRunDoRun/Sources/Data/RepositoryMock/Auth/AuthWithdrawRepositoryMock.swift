//
//  AuthWithdrawRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

final class AuthWithdrawRepositoryMock: AuthWithdrawRepository {
    func withdraw() async throws {
        print("[Mock] 회원탈퇴 성공")
    }
}
