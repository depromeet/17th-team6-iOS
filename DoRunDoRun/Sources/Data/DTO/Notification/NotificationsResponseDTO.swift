//
//  NotificationsResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

import Foundation

struct NotificationsResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: NotificationPageData
}

struct NotificationPageData: Decodable {
    let content: [NotificationItemDTO]
    let totalElements: Int
    let totalPages: Int
}

struct NotificationItemDTO: Decodable {
    let id: Int
    let title: String
    let message: String
    let sender: String?
    let profileImage: String?
    let type: String
    let isRead: Bool
    let relatedId: Int?
    let selfieImage: String?
    let createdAt: String
}

extension NotificationItemDTO {
    func toEntity() -> NotificationsResult {
        NotificationsResult(
            id: id,
            title: title,
            message: message,
            senderName: sender,
            profileImageURL: profileImage,
            type: NotificationType(rawValue: type) ?? .unknown,
            isRead: isRead,
            relatedId: relatedId,
            selfieImageURL: selfieImage,
            createdAt: createdAt
        )
    }
}

