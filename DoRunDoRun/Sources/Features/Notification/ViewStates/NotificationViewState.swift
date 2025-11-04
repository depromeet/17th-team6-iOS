//
//  NotificationViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

struct NotificationViewState: Equatable, Identifiable {
    let id: Int
    let title: String
    let message: String
    let senderName: String?
    let profileImageURL: String?
    let selfieImageURL: String?
    let timeText: String
    var isRead: Bool
    let type: NotificationType
}
