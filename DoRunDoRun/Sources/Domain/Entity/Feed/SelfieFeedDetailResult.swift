//
//  SelfieFeedDetailResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation

struct SelfieFeedDetailResult: Equatable {
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
    let reactions: [Reaction]
}
