//
//  NotificationReadRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/1/25.
//

final class NotificationReadRepositoryMock: NotificationReadRepository {
    func patchNotificationRead(notificationId: Int) async throws {
        print("[Mock] 알림 읽음 처리 성공: id = \(notificationId)")
    }
}
