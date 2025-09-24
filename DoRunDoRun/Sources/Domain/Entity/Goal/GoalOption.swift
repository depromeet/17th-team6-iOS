//
//  GoalOption.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/24/25.
//

import Foundation

struct GoalOption {
    let type: GoalOptionType
    let distance: [Int]         // m 단위
    let duration: [Int]         // 분 단위
    let pace: [Int]             // 초/킬로미터 단위 (서버가 분 단위를 기대하면 변환해서 보냄)
}

enum GoalOptionType: String {
    case marathon = "MARATHON"
    case stamina = "STAMINA"
    case zone2 = "ZONE_2"
}
