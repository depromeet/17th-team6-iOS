//
//  SelfieWeekRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

final class SelfieWeekRepositoryImpl: SelfieWeekRepository {
    private let service: SelfieFeedService

    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }

    func fetchWeeklySelfieCount(startDate: String, endDate: String) async throws -> [SelfieWeekCountResult] {
        let response = try await service.fetchWeeklySelfieCount(startDate: startDate, endDate: endDate)
        return response.toDomain()
    }
}

