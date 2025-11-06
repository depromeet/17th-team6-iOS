//
//  DateFormatterManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

final class DateFormatterManager {
    static let shared = DateFormatterManager()
    private init() {}
    
    // MARK: - Date → String
    private lazy var yearMonthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f
    }()
    
    private lazy var yearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy"
        return f
    }()
    
    private lazy var monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월"
        return f
    }()
    
    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "d"
        return f
    }()
    
    // MARK: - String → Date
    private lazy var isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    // MARK: - Helpers
    func date(from string: String, format: String = "yyyy-MM-dd") -> Date? {
        if format == "yyyy-MM-dd" {
            return isoFormatter.date(from: string)
        } else {
            let f = DateFormatter()
            f.locale = Locale(identifier: "ko_KR")
            f.dateFormat = format
            return f.date(from: string)
        }
    }
    
    func monthTitle(from date: Date) -> String {
        yearMonthFormatter.string(from: date)
    }
    
    func yearString(from date: Date) -> String {
        yearFormatter.string(from: date)
    }
    
    func monthString(from date: Date) -> String {
        monthFormatter.string(from: date)
    }
    
    func dayString(from date: Date) -> String {
        dayFormatter.string(from: date)
    }
}
