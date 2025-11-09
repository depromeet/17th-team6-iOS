//
//  DateFormatterManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

/// 앱 전역에서 사용하는 날짜·시간 포맷 매니저
/// - 숫자만 표시되는 포맷과 ‘년·월·일’ 단위가 포함된 Label 포맷을 구분합니다.
final class DateFormatterManager {
    static let shared = DateFormatterManager()
    private init() {}

    // MARK: - Formatters (Date → String)
    /// "yyyy" → 2025
    private lazy var formattedYear: DateFormatter = makeFormatter("yyyy")

    /// "M" → 11
    private lazy var formattedMonth: DateFormatter = makeFormatter("M")

    /// "M월" → 11월
    private lazy var formattedMonthLabel: DateFormatter = makeFormatter("M월")

    /// "yyyy년 M월" → 2025년 11월
    private lazy var formattedYearMonthLabel: DateFormatter = makeFormatter("yyyy년 M월")

    /// "d" → 7
    private lazy var formattedDay: DateFormatter = makeFormatter("d")
    
    /// "d일" → 7일
    private lazy var formattedDayLabel: DateFormatter = makeFormatter("d일")

    /// "yyyy.MM.dd" → 2025.11.07
    private lazy var formattedDateText: DateFormatter = makeFormatter("yyyy.MM.dd")

    /// "yyyy.MM.dd (E)" → 2025.11.07 (금)
    private lazy var formattedDateWithWeekdayText: DateFormatter = makeFormatter("yyyy.MM.dd (E)")

    /// "a h:mm" → 오전 10:15
    private lazy var formattedTime: DateFormatter = makeFormatter("a h:mm")

    /// "yyyy-MM-dd" (ISO)
    private lazy var formattedISODate: DateFormatter = makeFormatter("yyyy-MM-dd")

    // MARK: - Formatter Factory
    private func makeFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = format
        return f
    }

    // MARK: - String → Date
    func date(from string: String, format: String = "yyyy-MM-dd") -> Date? {
        if format == "yyyy-MM-dd" {
            return formattedISODate.date(from: string)
        } else {
            let f = makeFormatter(format)
            return f.date(from: string)
        }
    }
    
    // MARK: - String → Date (ISO 8601)
    func isoDate(from isoString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 마이크로초(.576007) 지원
        return formatter.date(from: isoString)
    }

    // MARK: - Date → String
    /// "yyyy" → 2025
    func formatYear(from date: Date) -> String { formattedYear.string(from: date) }

    /// "M" → 11
    func formatMonth(from date: Date) -> String { formattedMonth.string(from: date) }

    /// "M월" → 11월
    func formatMonthLabel(from date: Date) -> String { formattedMonthLabel.string(from: date) }

    /// "yyyy년 M월" → 2025년 11월
    func formatYearMonthLabel(from date: Date) -> String { formattedYearMonthLabel.string(from: date) }

    /// "d" → 7
    func formatDay(from date: Date) -> String { formattedDay.string(from: date) }
    
    /// "d일" → 7일
    func formatDayLabel(from date: Date) -> String { formattedDay.string(from: date) }

    /// "yyyy.MM.dd" → 2025.11.07
    func formatDateText(from date: Date) -> String { formattedDateText.string(from: date) }

    /// "yyyy.MM.dd (E)" → 2025.11.07 (금)
    func formatDateWithWeekdayText(from date: Date) -> String { formattedDateWithWeekdayText.string(from: date) }

    /// "a h:mm" → 오전 10:15
    func formatTime(from date: Date) -> String { formattedTime.string(from: date) }

    // MARK: - Relative Time (예: "3분 전", "5일 전")
    func formatRelativeTime(from isoString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: isoString) else { return "" }

        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        let years = Int(interval / (86400 * 365))

        switch interval {
        case ..<60:
            return "방금 전"
        case ..<3600:
            return "\(minutes)분 전"
        case ..<86400:
            return "\(hours)시간 전"
        case ..<(86400 * 365):
            return "\(days)일 전"
        default:
            return "\(years)년 전"
        }
    }
}
