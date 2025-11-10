//
//  SelfieFeedDeleteRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

final class SelfieFeedDeleteRepositoryMock: SelfieFeedDeleteRepository {
    func deleteFeed(feedId: Int) async throws  {
        print("[Mock] 피드 삭제 성공 (feedId: \(feedId))")
    }
}
