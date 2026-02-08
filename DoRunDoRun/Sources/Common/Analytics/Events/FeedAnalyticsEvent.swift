//
//  FeedAnalyticsEvent.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/2/26.
//

import Foundation

enum CreateFeedSource {
    case feedFab
    case runningDetail
    case sessionDetail
    
    var rawValue: String {
        switch self {
        case .feedFab:
            return "feed_fab"
        case .runningDetail:
            return "running_detail"
        case .sessionDetail:
            return "session_detail"
        }
    }
}

enum EntryPoint {
    case runningDetailAfterRun
    case runningDetailFromMy
    case selectSession
    case inputManual

    var rawValue: String {
        switch self {
        case .runningDetailAfterRun:
            return "running_detail_after_run"
        case .runningDetailFromMy:
            return "running_detail_from_my"
        case .selectSession:
            return "select_session"
        case .inputManual:
            return "input_manual"
        }
    }
}

enum FeedAnalyticsEvent {

    // MARK: CreateFeed Intent (퍼널 시작)
    case createFeedCtaClicked(
        source: CreateFeedSource,
        runningID: String?
    )

    // MARK: Sub Flow
    case sessionSelected(sessionID: String)
    case manualInputConfirmed

    // MARK: Entry
    case createFeedEntryCompleted(
        runningID: String?,
        entryPoint: EntryPoint
    )

    // MARK: Photo
    case photoChanged(source: String, fileSizeKB: Int)

    // MARK: Upload UX
    case uploadClicked(runningID: String?)
    
    // MARK: Result
    case uploadSucceeded(entryPoint: EntryPoint)
    case uploadFailed(errorCode: String)
}
