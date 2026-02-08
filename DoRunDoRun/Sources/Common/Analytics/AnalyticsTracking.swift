//
//  AnalyticsTracking.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 1/22/26.
//

import Foundation

protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}
