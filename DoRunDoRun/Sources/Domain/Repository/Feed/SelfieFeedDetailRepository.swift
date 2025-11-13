//
//  SelfieFeedDetailRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

protocol SelfieFeedDetailRepository {
    func fetch(feedId: Int) async throws -> SelfieFeedDetailResult
}
