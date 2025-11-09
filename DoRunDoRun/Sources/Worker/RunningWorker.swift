//
//  RunningWorker.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import Foundation

struct RunningWorker {
    private let repository: RunningRecordRepositoryProtocol

    init(repository: RunningRecordRepositoryProtocol = RunningRecordRepository()) {
        self.repository = repository
    }

    func runningRecords(isSelfied: Bool, startDateTime: Date?, endDateTime: Date?) async throws -> [RunningRecord] {
        return try await repository.runningRecords(isSelfied: isSelfied, startDateTime: startDateTime, endDateTime: endDateTime)
    }
}


protocol RunningRecordRepositoryProtocol {
    func runningRecords(isSelfied: Bool, startDateTime: Date?, endDateTime: Date?) async throws -> [RunningRecord]
}

struct RunningRecordRepository: RunningRecordRepositoryProtocol {
    private let service: NetworkService

    init(service: NetworkService = NetworkService()) {
        self.service = service
    }

    func runningRecords(isSelfied: Bool, startDateTime: Date?, endDateTime: Date?) async throws -> [RunningRecord] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let startString: String?
        if let startDateTime = startDateTime {
            startString = formatter.string(from: startDateTime)
        } else {
            startString = nil
        }
        let endString: String?
        if let endDateTime = endDateTime {
            endString = formatter.string(from: endDateTime)
        } else {
            endString = nil
        }
        service.decoder.dateDecodingStrategy = .iso8601
        let target = RunningAPI.searchRunnign(isSelfied: isSelfied, startDateTime: startString, endDateTime: endString)
        let response: RunningRecordContainerEntity = try await service.request(target: target)
        return response.data.map { RunningRecordMapper.toDomain(from: $0) }
    }
}


struct RunningRecordRepositoryMock: RunningRecordRepositoryProtocol {
    let service: NetworkService

    init(service: NetworkService = NetworkService(type: .stubbing)) {
        self.service = service
    }

    func runningRecords(isSelfied: Bool, startDateTime: Date?, endDateTime: Date?) async throws -> [RunningRecord] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let startString: String?
        if let startDateTime = startDateTime {
            startString = formatter.string(from: startDateTime)
        } else {
            startString = nil
        }
        let endString: String?
        if let endDateTime = endDateTime {
            endString = formatter.string(from: endDateTime)
        } else {
            endString = nil
        }
        service.decoder.dateDecodingStrategy = .iso8601
        let target = RunningAPI.searchRunnign(isSelfied: isSelfied, startDateTime: startString, endDateTime: endString)
        let response: RunningRecordContainerEntity = try await service.request(target: target)
        return response.data.map { RunningRecordMapper.toDomain(from: $0) }
    }
}
