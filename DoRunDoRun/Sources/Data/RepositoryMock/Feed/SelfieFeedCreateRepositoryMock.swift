//
//  SelfieFeedCreateRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation

final class SelfieFeedCreateRepositoryMock: SelfieFeedCreateRepository {
    func createFeed(data: SelfieFeedCreateRequestDTO, selfieImage: Data?) async throws {
        print("[Mock] 피드 생성 성공 (runSessionId: \(data.runSessionId))")
    }
}
