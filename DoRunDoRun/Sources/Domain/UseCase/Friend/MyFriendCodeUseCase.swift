//
//  MyFriendCodeUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

protocol MyFriendCodeUseCaseProtocol {
    func execute() async throws -> MyFriendCode
}

final class MyFriendCodeUseCase: MyFriendCodeUseCaseProtocol {
    private let repository: MyFriendCodeRepository

    init(repository: MyFriendCodeRepository = MyFriendCodeRepositoryImpl()) {
        self.repository = repository
    }

    func execute() async throws -> MyFriendCode {
        try await repository.generateMyFriendCode()
    }
}
