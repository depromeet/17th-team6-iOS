//
//  AnalyticsEvent.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/2/26.
//

import Foundation

enum AnalyticsEvent {
    case screenViewed(Screen)
    case running(RunningAnalyticsEvent)
    case feed(FeedAnalyticsEvent)
    case ad(AdAnalyticsEvent)
    case my(MyAnalyticsEvent)
}
