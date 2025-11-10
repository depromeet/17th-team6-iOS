//
//  SelfieFeedUpdateRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

final class SelfieFeedUpdateRepositoryMock: SelfieFeedUpdateRepository {
    func updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResult {
        print("[Mock] 피드 수정 성공 (feedId: \(feedId))")
        return SelfieFeedUpdateResult(feedId: feedId, updatedImageUrl: "https://mock.s3.amazonaws.com/selfie123.jpg")
    }
}
