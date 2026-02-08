//
//  NotificationListView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI
import ComposableArchitecture

struct NotificationListView: View {
    @Perception.Bindable var store: StoreOf<NotificationListFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
            .task { store.send(.onAppear) }
            .navigationTitle("알림")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        store.send(.backButtonTapped)
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

// MARK: - Server Error Section
private extension NotificationListView {
    /// Server Error Section
    @ViewBuilder
    var serverErrorSection: some View {
        if let serverErrorType = store.serverError.serverErrorType {
            ServerErrorView(serverErrorType: serverErrorType) {
                store.send(.serverError(.retryButtonTapped))
            }
        }
    }
}

// MARK: - Main Section
private extension NotificationListView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(spacing: 0) {
                if store.notifications.isEmpty {
                    NotificationEmptyView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(store.notifications) { notification in
                                NotificationRowView(notification: notification) {
                                    store.send(.notificationTapped(notification))
                                }
                                .onAppear {
                                    if notification.id == store.notifications.last?.id {
                                        store.send(.loadNextPageIfNeeded(currentItem: notification))
                                    }
                                }
                            }
                            if store.isLoading && store.currentPage > 0 {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Network Error Popup Section
private extension NotificationListView {
    /// Networ Error Popup Section
    @ViewBuilder
    var networkErrorPopupSection: some View {
        if store.networkErrorPopup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                NetworkErrorPopupView {
                    store.send(.networkErrorPopup(.retryButtonTapped))
                }
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(10)
        }
    }
}
