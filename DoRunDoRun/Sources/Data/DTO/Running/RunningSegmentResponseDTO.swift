//
//  RunningSegmentResponseDTO.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

// MARK: - Response Root
struct RunningSegmentResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: SegmentSaveDataDTO
}

struct SegmentSaveDataDTO: Decodable {
    let segmentId: Int
    let savedCount: Int
}
