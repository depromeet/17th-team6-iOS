//
//  SelfieUploadableResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation

struct SelfieUploadableResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: SelfieUploadableDTO
}

struct SelfieUploadableDTO: Decodable {
    let isUploadable: Bool
    let reason: String?
}

extension SelfieUploadableResponseDTO {
    func toDomain() -> SelfieUploadableResult {
        let reason = UploadableReason(rawValue: data.reason ?? "") ?? .unknown

        return SelfieUploadableResult(
            isUploadable: data.isUploadable,
            reason: reason
        )
    }
}
