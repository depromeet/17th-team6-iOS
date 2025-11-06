//
//  SelfieFeedRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

final class SelfieFeedRepositoryImpl: SelfieFeedRepository {
    private let service: SelfieFeedService

    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }

    func fetchFeeds(currentDate: String?, userId: Int?, page: Int, size: Int) async throws -> SelfieFeedResult {
        let dto = try await service.fetchFeeds(currentDate: currentDate, userId: userId, page: page, size: size)
        let feeds = dto.data.feeds.contents.map { $0.toDomain() }
        let summary = dto.data.userSummary.toDomain()
        return SelfieFeedResult(userSummary: summary, feeds: feeds)
    }}
