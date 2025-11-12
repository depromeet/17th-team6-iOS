//
//  SelfieFeedCreateUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation

protocol SelfieFeedCreateUseCaseProtocol {
    func execute(data: SelfieFeedCreateRequestDTO, selfieImage: Data?) async throws
}

final class SelfieFeedCreateUseCase: SelfieFeedCreateUseCaseProtocol {
    private let repository: SelfieFeedCreateRepository

    init(repository: SelfieFeedCreateRepository = SelfieFeedCreateRepositoryImpl()) {
        self.repository = repository
    }

    func execute(data: SelfieFeedCreateRequestDTO, selfieImage: Data?) async throws {
        try await repository.createFeed(data: data, selfieImage: selfieImage)
    }
}
