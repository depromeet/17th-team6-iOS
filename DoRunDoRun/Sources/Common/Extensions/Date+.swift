//
//  Date+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/2/25.
//

import Foundation

extension Date? {
    func relativeTimeString() -> String {
        guard let date = self else { return "알 수 없음" }

        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        let seconds = Int(timeInterval)

        let minutes = seconds / 60
        let hours = seconds / 3600
        let days = seconds / 86400

        if seconds < 3600 { // 1시간 미만
            return "\(minutes)분 전"
        } else if seconds < 86400 { // 1일 미만
            return "\(hours)시간 전"
        } else { // 1일 이상
            return "\(days)일 전"
        }
    }
}


extension Date {
    static func convertStringToDate(_ dateString: String) -> Date? {
        // ISO8601 형식을 자동으로 파싱
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }
}

extension Date {
    func toFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy.MM.dd · a h:mm"

        return formatter.string(from: self)
    }
}
