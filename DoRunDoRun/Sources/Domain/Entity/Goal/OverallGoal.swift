//
//  OverallGoal.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

struct OverallGoal {
    let id: Int
    let createdAt: Date
    let updatedAt: Date
    let pausedAt: Date?
    let clearedAt: Date?
    let title: String
    let subTitle: String
    let type: String
    let pace: Int
    let distance: Int
    let duration: Int
    let currentRoundCount: Int
    let totalRoundCount: Int
}
