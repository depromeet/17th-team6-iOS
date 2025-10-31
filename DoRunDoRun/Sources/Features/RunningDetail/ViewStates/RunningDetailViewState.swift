//
//  RunningDetailViewState.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/31/25.
//

import Foundation

struct RunningDetailViewState: Equatable {
    let finishedAtText: String
    let totalDistanceText: String
    let avgPaceText: String
    let durationText: String
    let cadenceText: String
    
    let mapImageURL: URL?
    let feed: FeedSummary?
}
