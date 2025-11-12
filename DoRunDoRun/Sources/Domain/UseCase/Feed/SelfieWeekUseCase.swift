//
//  SelfieWeekUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

protocol SelfieWeekUseCaseProtocol {
    func execute(startDate: String, endDate: String) async throws -> [SelfieWeekCountResult]
}

final class SelfieWeekUseCase: SelfieWeekUseCaseProtocol {
    private let repository: SelfieWeekRepository

    init(repository: SelfieWeekRepository = SelfieWeekRepositoryImpl()) {
        self.repository = repository
    }

    func execute(startDate: String, endDate: String) async throws -> [SelfieWeekCountResult] {
        try await repository.fetchWeeklySelfieCount(startDate: startDate, endDate: endDate)
    }
}
