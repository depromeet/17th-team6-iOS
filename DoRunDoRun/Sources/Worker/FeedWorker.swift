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

    func plusReaction(feedID: Int, emojiType: Emoji) async throws {
        try await repository.plusReaction(feedID: feedID, emojiType: emojiType.rawValue)
    }

    func certificatedFriends(date: String) async throws -> [CertificatedFriend] {
        return try await repository.certificatedFriends(date: date)
    }
}

protocol FeedRepositoryProtocol {
    func feedList(currentDate: String, userId: Int, page: Int, size: Int) async throws -> FeedList
    func plusReaction(feedID: Int, emojiType: String) async throws
    func certificatedFriends(date: String) async throws -> [CertificatedFriend]
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

    func plusReaction(feedID: Int, emojiType: String) async throws {
        let target = FeedAPI.plusReaction(feedID: feedID, emojiType: emojiType)
        let _: EmptyEntity = try await service.request(target: target)
    }

    /// date: "2024-11-01"
    func certificatedFriends(date: String) async throws -> [CertificatedFriend] {
        let target = FeedAPI.certificatedFriends(date: date)
        let entity: CerificatedFriendsContainerEntity = try await service.request(target: target)
        let domain = CertificatedFriendsMapper.toDomain(entity)
        return domain
    }
}

enum FeedError: Error {
    case unknownError
}

struct EmptyEntity: Decodable {}
