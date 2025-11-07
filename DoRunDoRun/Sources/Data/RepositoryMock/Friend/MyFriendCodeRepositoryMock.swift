//
//  MyFriendCodeRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

final class MyFriendCodeRepositoryMock: MyFriendCodeRepository {
    func generateMyFriendCode() async throws -> MyFriendCode {
        return MyFriendCode(code: "mock1234")
    }
}
