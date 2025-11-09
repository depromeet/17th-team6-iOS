//
//  String+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/2/25.
//

import Foundation

extension String {
    func relativeTimeString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: self) else {
            return "알 수 없음"
        }

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
