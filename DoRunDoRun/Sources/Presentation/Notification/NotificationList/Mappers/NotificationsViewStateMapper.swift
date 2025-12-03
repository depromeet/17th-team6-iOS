//
//  NotificationsViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import Foundation

struct NotificationsViewStateMapper {
    static func map(from entity: NotificationsResult) -> NotificationsViewState {
        let formatter = DateFormatterManager.shared
        let timeText = formatter.formatRelativeTime(from: entity.createdAt)

        return NotificationsViewState(
            id: entity.id,
            title: entity.title,
            message: entity.message,
            senderName: entity.senderName,
            profileImageURL: entity.profileImageURL,
            selfieImageURL: entity.selfieImageURL,
            timeText: timeText,
            isRead: entity.isRead,
            type: entity.type,
            relatedId: entity.relatedId
        )
    }
}
