//
//  RunningSessionSummaryViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/05/25.
//

import Foundation

enum CertificationStatus: Equatable {
    case possible
    case completed
    case none
}

struct RunningSessionSummaryViewState: Identifiable, Equatable {
    let id: Int
    let date: Date
    let dateText: String        // ex. "2025.09.30 (화)"
    let timeText: String        // ex. "오전 10:11"
    let distanceText: String    // ex. "8.02km"
    let durationText: String    // ex. "01:12:03"
    let paceText: String        // ex. "6'74\""
    let spmText: String         // ex. "128 spm"
    let tagStatus: CertificationStatus
    let mapImageURL: String?
}
