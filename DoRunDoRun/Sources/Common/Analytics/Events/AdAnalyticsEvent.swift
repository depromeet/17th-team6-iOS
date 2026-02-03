//
//  AdAnalyticsEvent.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/2/26.
//

import Foundation

enum AdAnalyticsEvent {
    case adDisplaySucceeded
    case adDisplayFailed(errorCode: String)
}
