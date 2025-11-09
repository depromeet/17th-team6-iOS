//
//  UploadFeedModels.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import Foundation

// MARK: - RunningRecordContainerEntity
struct RunningRecordContainerEntity: Decodable {
    let status, message, timestamp: String
    let data: [RunningRecordEntity]
}

// MARK: - RunningRecordEntity
struct RunningRecordEntity: Decodable {
    let runSessionId: Int
    let createdAt, updatedAt, finishedAt: Date
    let distanceTotal, durationTotal, paceAvg, cadenceAvg: Int
    let isSelfied: Bool
    let mapImage: String
}


// MARK: RunningRecord: Domain
struct RunningRecord {
    let runSessionID: Int
    let createdAt: Date
    let distanceTotal: Int
    let durationTotal: Int
    let paceAvg: Int
    let cadanceAvg: Int
    let isSelfied: Bool
    let mapImageURL: URL?
}


// MARK: Mapper
enum RunningRecordMapper {
    static func toDomain(from entity: RunningRecordEntity) -> RunningRecord {
        return RunningRecord(
            runSessionID: entity.runSessionId,
            createdAt: entity.createdAt,
            distanceTotal: entity.distanceTotal,
            durationTotal: entity.durationTotal,
            paceAvg: entity.paceAvg,
            cadanceAvg: entity.cadenceAvg,
            isSelfied: entity.isSelfied,
            mapImageURL: URL(string: entity.mapImage)
        )
    }
}
