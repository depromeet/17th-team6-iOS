//
//  NotificationsResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import Foundation

/// 서버로부터 받은 알림 정보를 앱 내부에서 사용하는 도메인 모델
struct NotificationsResult: Equatable, Identifiable {
    let id: Int
    let title: String
    let message: String
    let senderName: String?
    let profileImageURL: String?
    let type: NotificationType
    let isRead: Bool
    let relatedId: Int?
    let selfieImageURL: String?
    let createdAt: String
}

enum NotificationType: String, Decodable {
    case cheerFriend = "CHEER_FRIEND"
    case feedUploaded = "FEED_UPLOADED"
    case feedReaction = "FEED_REACTION"
    case feedReminder = "FEED_REMINDER"
    case runningProgressReminder = "RUNNING_PROGRESS_REMINDER"
    case newUserRunningReminder = "NEW_USER_RUNNING_REMINDER"
    case newUserFriendReminder = "NEW_USER_FRIEND_REMINDER"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try? container.decode(String.self)
        self = NotificationType(rawValue: value ?? "") ?? .unknown
    }
}
