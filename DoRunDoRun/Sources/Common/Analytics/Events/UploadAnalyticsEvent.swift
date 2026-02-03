//
//  UploadAnalyticsEvent.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/2/26.
//

import Foundation

enum UploadAnalyticsEvent {
    case uploadSucceeded(postID: String)
    case uploadFailed(errorCode: String)
}
