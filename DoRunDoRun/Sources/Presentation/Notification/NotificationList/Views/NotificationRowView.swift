//
//  NotificationRowView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI
import Kingfisher

struct NotificationRowView: View {
    let notification: NotificationsViewState
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                switch notification.type {
                case .runningProgressReminder:
                    Image(.notification1)
                        .frame(width: 52, height: 52)
                case .newUserFriendReminder:
                    Image(.notification2)
                        .frame(width: 52, height: 52)
                case .newUserRunningReminder:
                    Image(.notification3)
                        .frame(width: 52, height: 52)
                default:
                    ProfileImageView(
                        image: Image(.profilePlaceholder),
                        imageURL: notification.profileImageURL,
                        style: .grayBorder,
                        size: .large
                    )
                }
                VStack(alignment: .leading, spacing: 2) {
                    if let nickname = notification.senderName {
                        TypographyHighlightText(
                            text: notification.message, target: "\(nickname) 님",
                            baseStyle: .b2_400,
                            baseColor: .gray900,
                            highlightStyle: .b2_700,
                            highlightColor: .gray900,
                            alignment: .left,
                            fixedSize: false
                        )
                    } else {
                        TypographyText(text: notification.message, style: .b2_400, alignment: .left)
                    }
                    TypographyText(text: notification.timeText, style: .c1_500, color: .gray500, alignment: .left)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let selfieImageURL = notification.selfieImageURL,
                    let urlString = URL(string: selfieImageURL) {
                    KFImage(urlString)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .cornerRadius(8)
                        .clipped()
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 86)
        .frame(maxWidth: .infinity)
        .background(notification.isRead ? Color.gray0 : Color.blue100)
        .animation(.easeInOut(duration: 0.25), value: notification.isRead)
        .onTapGesture { onTap() }
    }
}
