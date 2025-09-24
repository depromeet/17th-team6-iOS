//
//  GoalOption.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

struct GoalOption {
    let type: GoalOptionType
    /// m 단위
    let distance: [Int]
    /// 분 단위
    let duration: [Int]
    // 초/킬로미터 단위
    let pace: [Int]
}

enum GoalOptionType: String {
    case marathon = "MARATHON"
    case stamina = "STAMINA"
    case zone2 = "ZONE_2"
}
