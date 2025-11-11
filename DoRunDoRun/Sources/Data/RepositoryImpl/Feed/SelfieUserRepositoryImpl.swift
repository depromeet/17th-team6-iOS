//
//  SelfieUserRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

final class SelfieUserRepositoryImpl: SelfieUserRepository {
    private let service: SelfieFeedService

    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }

    func fetchUsersByDate(date: String) async throws -> [SelfieUserResult] {
        let dto = try await service.fetchUsersByDate(date: date)
        return dto.data.users.map { $0.toDomain() }
    }
}
