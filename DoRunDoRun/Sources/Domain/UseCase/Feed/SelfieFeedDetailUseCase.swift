//
//  SelfieFeedDetailUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

protocol SelfieFeedDetailUseCaseProtocol {
    func execute(feedId: Int) async throws -> SelfieFeedDetailResult
}

struct SelfieFeedDetailUseCase: SelfieFeedDetailUseCaseProtocol {
    let repository: SelfieFeedDetailRepository
    
    func execute(feedId: Int) async throws -> SelfieFeedDetailResult {
        try await repository.fetch(feedId: feedId)
    }
}
