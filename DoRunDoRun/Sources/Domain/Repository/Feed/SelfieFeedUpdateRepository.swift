//
//  SelfieFeedUpdateRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

protocol SelfieFeedUpdateRepository {
    /// 인증피드 수정
    func updateFeed(feedId: Int, data: SelfieFeedUpdateRequestDTO, selfieImage: Data?) async throws -> SelfieFeedUpdateResult
}
