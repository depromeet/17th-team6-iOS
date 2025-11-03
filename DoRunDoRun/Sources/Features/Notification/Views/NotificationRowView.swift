//
//  NotificationRowView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI
import Kingfisher

struct NotificationRowView: View {
    let notification: NotificationViewState
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ProfileImageView(
                    image: Image(.profilePlaceholder),
                    imageURL: notification.profileImageURL,
                    style: .grayBorder,
                    size: .large
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    if let nickname = notification.senderName {
                        TypographyHighlightText(
                            text: notification.message, target: "\(nickname) 님",
                            baseStyle: .b2_400, baseColor: .gray900,
                            highlightStyle: .b2_700,
                            highlightColor: .gray900,
                            fixedSize: false
                        )
                    } else {
                        TypographyText(text: notification.message, style: .b2_400, alignment: .left)
                    }
                    TypographyText(text: notification.timeText, style: .c1_500, color: .gray500, alignment: .left)
                }
                .frame(maxWidth: .infinity)
                
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

// MARK: - Preview
#Preview("읽지 않은 알림") {
    NotificationRowView(
        notification: NotificationViewState(
            id: 1,
            title: "리액션 알림",
            message: "이 회원님의 게시물에 리액션을 남겼습니다.",
            senderName: "두런두런두런두런",
            profileImageURL: "https://example.com/profile1.jpg",
            selfieImageURL: "https://example.com/post1.jpg",
            timeText: "1시간 전",
            isRead: false
        ),
        onTap: {}
    )
}

#Preview("읽은 알림") {
    NotificationRowView(
        notification: NotificationViewState(
            id: 2,
            title: "리액션 알림",
            message: "이 회원님의 게시물에 리액션을 남겼습니다.",
            senderName: "두런두런두런두런",
            profileImageURL: "https://example.com/profile1.jpg",
            selfieImageURL: "https://example.com/post1.jpg",
            timeText: "1시간 전",
            isRead: true
        ),
        onTap: {}
    )
}


