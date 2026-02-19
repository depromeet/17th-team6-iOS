//
//  ManualSessionRequestDTO.swift
//  DoRunDoRun
//
//  Created by Claude on 2/19/26.
//

import Foundation

struct ManualSessionRequestDTO: Encodable {
    let startedAt: String   // ISO8601
    let durationTotal: Int  // 초
    let distanceTotal: Int  // 미터
    let paceAvg: Int        // 초/km
    let cadenceAvg: Int     // spm
}
