//
//  CalendarManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

final class CalendarManager {
    static let shared = CalendarManager()
    private init() {}

    private(set) lazy var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "ko_KR")
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }()
    
    func dateOneYearAgo(from date: Date = Date()) -> Date {
        calendar.date(byAdding: .year, value: -1, to: date) ?? date
    }
}
