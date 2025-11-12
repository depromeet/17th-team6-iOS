//
//  SelfieFeedCreateRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation

protocol SelfieFeedCreateRepository {
    func createFeed(data: SelfieFeedCreateRequestDTO, selfieImage: Data?) async throws
}
