//
//  NotificationView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI
import ComposableArchitecture

struct NotificationView: View {
    @Perception.Bindable var store: StoreOf<NotificationFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if store.notifications.isEmpty {
                    EmptyNotificationView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(store.notifications) { notification in
                                NotificationRowView(notification: notification) {
                                    store.send(.markAsRead(notification.id))
                                }
                            }
                        }
                    }
                }
            }
            .task { store.send(.onAppear) }
            .navigationTitle("알림")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        //store.send(.backButtonTapped)
                    } label: {
                        Image(.arrowLeft, size: .medium)
                            .renderingMode(.template)
                            .foregroundColor(.gray800)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        NotificationView(
            store: Store(
                initialState: NotificationFeature.State(
                    notifications: [
                        .init(
                            id: 1,
                            title: "피드 리액션",
                            message: "이 회원님의 게시물에 리액션을 남겼습니다.",
                            senderName: "두런두런두런두런",
                            profileImageURL: "https://example.com/profile1.jpg",
                            selfieImageURL: "https://example.com/post1.jpg",
                            timeText: "1시간 전",
                            isRead: false
                        ),
                        .init(
                            id: 2,
                            title: "러닝 독촉",
                            message: "오랜만에 힘차게 달려볼까요?",
                            senderName: nil,
                            profileImageURL: nil,
                            selfieImageURL: nil,
                            timeText: "2시간 전",
                            isRead: true
                        )
                    ]
                ),
                reducer: { NotificationFeature() }
            )
        )
    }
}
