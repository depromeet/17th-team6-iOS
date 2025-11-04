//
//  NotificationViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import Foundation

struct NotificationViewStateMapper {
    static func map(from entity: NotificationsResult) -> NotificationViewState {
        let timeText = makeTimeText(from: entity.createdAt)

        return NotificationViewState(
            id: entity.id,
            title: entity.title,
            message: entity.message,
            senderName: entity.senderName,
            profileImageURL: entity.profileImageURL,
            selfieImageURL: entity.selfieImageURL,
            timeText: timeText,
            isRead: entity.isRead,
            type: entity.type
        )
    }

    private static func makeTimeText(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        switch interval {
        case ..<60:
            return "방금 전"
        case ..<3600:
            return "\(minutes)분 전"
        case ..<86400:
            return "\(hours)시간 전"
        case ..<(86400 * 2):
            return "어제"
        case ..<(86400 * 7):
            return "\(days)일 전"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: date)
        }
    }
}
