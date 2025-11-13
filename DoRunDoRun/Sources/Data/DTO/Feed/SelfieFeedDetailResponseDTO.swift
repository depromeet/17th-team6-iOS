//
//  SelfieFeedDetailResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

struct SelfieFeedDetailResponseDTO: Codable {
    let status: String
    let message: String
    let timestamp: String
    let data: SelfieFeedDetailDTO
}

struct SelfieFeedDetailDTO: Codable {
    let feedId: Int
    let userId: Int
    let date: String
    let userName: String
    let profileImageUrl: String
    let isMyFeed: Bool
    let selfieTime: String
    let totalDistance: Double
    let totalRunTime: Double
    let averagePace: Double
    let cadence: Int
    let imageUrl: String
    let reactions: [ReactionDTO]
}

extension SelfieFeedDetailDTO {
    func toDomain() -> SelfieFeedDetailResult {
        return SelfieFeedDetailResult(
            feedId: feedId,
            userId: userId,
            date: date,
            userName: userName,
            profileImageUrl: profileImageUrl,
            isMyFeed: isMyFeed,
            selfieTime: selfieTime,
            totalDistance: totalDistance,
            totalRunTime: totalRunTime,
            averagePace: averagePace,
            cadence: cadence,
            imageUrl: imageUrl,
            reactions: reactions.map { $0.toDomain() }
        )
    }
}
