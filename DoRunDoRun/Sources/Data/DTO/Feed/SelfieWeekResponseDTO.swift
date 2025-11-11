//
//  SelfieWeekResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

struct SelfieWeekResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: SelfieWeekDataDTO
}

struct SelfieWeekDataDTO: Decodable {
    let countList: [SelfieWeekCountDTO]
}

struct SelfieWeekCountDTO: Decodable {
    let date: String
    let selfieCount: Int
}

extension SelfieWeekResponseDTO {
    func toDomain() -> [SelfieWeekCountResult] {
        data.countList.map { $0.toDomain() }
    }
}

extension SelfieWeekCountDTO {
    func toDomain() -> SelfieWeekCountResult {
        .init(date: date, selfieCount: selfieCount)
    }
}
