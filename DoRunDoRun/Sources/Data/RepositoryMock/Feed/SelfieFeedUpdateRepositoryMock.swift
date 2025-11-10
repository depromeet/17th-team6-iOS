//
//  SelfieFeedUpdateRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

final class SelfieFeedUpdateRepositoryMock: SelfieFeedUpdateRepository {
    func updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResponseDTO {
        print("[Mock] 피드 수정 성공 (feedId: \(feedId))")
        return SelfieFeedUpdateResponseDTO(
            status: "CONTINUE",
            message: "Mock 피드 수정 성공",
            timestamp: Date().ISO8601Format(),
            data: [:]
        )
    }
}
