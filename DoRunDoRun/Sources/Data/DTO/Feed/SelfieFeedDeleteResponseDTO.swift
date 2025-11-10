//
//  SelfieFeedDeleteResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

/// 인증피드 삭제 응답 DTO
struct SelfieFeedDeleteResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: [String: String]?
}
