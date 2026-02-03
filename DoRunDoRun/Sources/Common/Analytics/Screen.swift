//
//  Screen.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/1/26.
//

import Foundation

enum Screen {
    case runningDetail
    case sessionDetail
    case feed
    case selectSession
    case inputManual
    case createFeed
    case uploadSuccess
    case ad
    case my
}

extension Screen {
    var name: String {
        switch self {
        case .runningDetail: return "running_detail"
        case .sessionDetail: return "session_detail"
        case .feed: return "feed"
        case .selectSession: return "select_session"
        case .inputManual: return "input_manual"
        case .createFeed: return "create_feed"
        case .uploadSuccess: return "upload_success"
        case .ad: return "ad"
        case .my: return "my"
        }
    }

    var className: String {
        switch self {
        case .runningDetail: return "RunningDetailView"
        case .sessionDetail: return "SessionDetailView"
        case .feed: return "FeedView"
        case .selectSession: return "SelectSessionView"
        case .inputManual: return "InputManualView"
        case .createFeed: return "CreateFeedView"
        case .uploadSuccess: return "UploadSuccessView"
        case .ad: return "AdView"
        case .my: return "MyView"
        }
    }
}
