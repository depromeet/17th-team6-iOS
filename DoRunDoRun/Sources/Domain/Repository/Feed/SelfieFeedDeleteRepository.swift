//
//  SelfieFeedDeleteRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

protocol SelfieFeedDeleteRepository {
    /// 인증피드 삭제
    func deleteFeed(feedId: Int) async throws
}
