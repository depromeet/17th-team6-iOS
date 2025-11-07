//
//  MyFriendCodeRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

final class MyFriendCodeRepositoryImpl: MyFriendCodeRepository {
    private let service: FriendService

    init(service: FriendService = FriendServiceImpl()) {
        self.service = service
    }

    func generateMyFriendCode() async throws -> MyFriendCode {
        let dto = try await service.generateMyFriendCode()
        return MyFriendCode(code: dto.data.code)
    }
}
