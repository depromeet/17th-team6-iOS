//
//  RunningStartResponseDTO.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

// MARK: - Response Root
struct RunningStartResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: RunningStartDataDTO
}

struct RunningStartDataDTO: Decodable {
    let sessionId: Int
}
