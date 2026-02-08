//
//  AnalyticsDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 1/22/26.
//

import Dependencies

enum AnalyticsTrackerKey: DependencyKey {
    static let liveValue: AnalyticsTracking = AnalyticsTracker()
}

extension DependencyValues {
    var analyticsTracker: AnalyticsTracking {
        get { self[AnalyticsTrackerKey.self] }
        set { self[AnalyticsTrackerKey.self] = newValue }
    }
}
