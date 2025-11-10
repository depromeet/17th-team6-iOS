//
//  SelfieFeedUpdateResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

/// 인증피드 수정 응답 DTO
struct SelfieFeedUpdateResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: SelfieFeedUpdateDataDTO?
}

struct SelfieFeedUpdateDataDTO: Decodable {
    let selfieImageUrl: String
}

extension SelfieFeedUpdateDataDTO {
    func toDomain(feedId: Int) -> SelfieFeedUpdateResult {
        .init(feedId: feedId, updatedImageUrl: selfieImageUrl)
    }
}
