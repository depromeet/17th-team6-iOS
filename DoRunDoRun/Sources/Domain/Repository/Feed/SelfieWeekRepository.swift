//
//  SelfieWeekRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

protocol SelfieWeekRepository {
    func fetchWeeklySelfieCount(startDate: String, endDate: String) async throws -> [SelfieWeekCountResult]
}
