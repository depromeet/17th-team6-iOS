//
//  FeedWorker.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/31/25.
//

import Foundation

struct FeedWorker {
    private let repository: FeedRepositoryProtocol

    init(repository: FeedRepositoryProtocol = FeedRepository()) {
        self.repository = repository
    }

    func feedList(currentDate: String, userId: Int, page: Int, size: Int) async throws -> FeedList {
        return try await repository.feedList(currentDate: currentDate, userId: userId, page: page, size: size)
    }
}

protocol FeedRepositoryProtocol {
    func feedList(currentDate: String, userId: Int, page: Int, size: Int) async throws -> FeedList
}

struct FeedRepository: FeedRepositoryProtocol {
    private let service: NetworkService

    init(type: CustomProvider.ProviderType = .live) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.service = NetworkService(type: type)
    }

    func feedList(currentDate: String, userId: Int, page: Int, size: Int) async throws ->  FeedList {
        let target = FeedAPI.feedList(currentDate: currentDate, userId: userId, page: page, size: size)

        guard let entity: FeedListContainerEntity = try await service.request(target: target) else { throw FeedError.unknownError  }
        let domain = FeedListMapper.toDomain(from: entity)

        return domain
    }
}

enum FeedError: Error {
    case unknownError
}
