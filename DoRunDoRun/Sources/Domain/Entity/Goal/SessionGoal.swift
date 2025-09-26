//
//  SessionGoal.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import Foundation

struct SessionGoal {
    let id: Int
    let createdAt: Date
    let updatedAt: Date
    let clearedAt: Date?
    let goalId: Int
    let pace: Int
    let distance: Int
    let duration: Int
    let roundCount: Int
}
