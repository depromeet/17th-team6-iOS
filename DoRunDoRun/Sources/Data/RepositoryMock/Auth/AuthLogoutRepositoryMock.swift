//
//  AuthLogoutRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

final class AuthLogoutRepositoryMock: AuthLogoutRepository {
    func logout() async throws {
        print("[Mock] 로그아웃 성공")
    }
}
