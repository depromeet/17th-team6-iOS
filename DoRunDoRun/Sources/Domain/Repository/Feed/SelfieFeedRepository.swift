//
//  SelfieFeedRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

protocol SelfieFeedRepository {
    func fetchFeeds(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResult
}
