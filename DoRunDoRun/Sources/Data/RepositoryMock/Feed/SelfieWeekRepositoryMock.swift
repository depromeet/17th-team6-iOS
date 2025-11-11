//
//  SelfieWeekRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

final class SelfieWeekRepositoryMock: SelfieWeekRepository {
    func fetchWeeklySelfieCount(startDate: String, endDate: String) async throws -> [SelfieWeekCountResult] {
        return [
            .init(date: "2025-09-20", selfieCount: 3),
            .init(date: "2025-09-21", selfieCount: 5),
            .init(date: "2025-09-22", selfieCount: 7),
            .init(date: "2025-09-23", selfieCount: 0),
            .init(date: "2025-09-24", selfieCount: 2),
            .init(date: "2025-09-25", selfieCount: 4),
            .init(date: "2025-09-26", selfieCount: 1)
        ]
    }
}
