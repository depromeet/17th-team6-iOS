//
//  NotificationUnreadCountResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/15/25.
//

struct NotificationUnreadCountResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: Int
}

extension NotificationUnreadCountResponseDTO {
    func toEntity() -> NotificationUnreadCountResult {
        NotificationUnreadCountResult(count: data)
    }
}
