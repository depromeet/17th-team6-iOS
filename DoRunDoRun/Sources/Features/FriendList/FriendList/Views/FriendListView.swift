//
//  FriendListView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import SwiftUI
import ComposableArchitecture

struct FriendListView: View {
    @Perception.Bindable var store: StoreOf<FriendListFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                toastAndButtonSection
                popupSection
                networkErrorPopupSection
            }
            .onAppear { store.send(.onAppear) }
            .navigationTitle("친구")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
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
            .navigationDestination(
                item: $store.scope(state: \.friendCodeInput, action: \.friendCodeInput)
            ) { store in
                FriendCodeInputView(store: store)
            }
        }
    }
}

// MARK: - Server Error Section
private extension FriendListView {
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
private extension FriendListView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        VStack(alignment: .leading) {
            headerSection
            friendListSection
                .padding(.bottom, 129)
            Spacer()
        }
    }
    // 헤더 섹션
    var headerSection: some View {
        HStack(spacing: 8) {
            TypographyText(text: "친구목록", style: .t1_700, color: .gray800)
            TypographyText(text: "\(store.friends.count)", style: .t1_700, color: .gray500)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    /// 친구 목록 섹션
    @ViewBuilder
    var friendListSection: some View {
        if store.friends.isEmpty {
            FriendListEmptyView()
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.friends, id: \.renderId) { friend in
                        FriendListRowView(friend: friend) {
                            store.send(.showDeletePopup(friend.id))
                        }
                        .onAppear {
                            if friend.id == store.friends.last?.id {
                                store.send(.loadNextPageIfNeeded(currentItem: friend))
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

// MARK: - Toast & Button
private extension FriendListView {
    var toastAndButtonSection: some View {
        VStack(spacing: 0) {
            if store.toast.isVisible {
                ActionToastView(message: store.toast.message)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.3), value: store.toast.isVisible)
            }

            AppButton(title: "친구 코드 입력하기", style: .primary, size: .fullWidth) {
                store.send(.friendCodeInputButtonTapped)
            }
            .padding(.top, 8)
            .padding(.horizontal, 20)
            .background(Color.gray0)

            AppButton(title: "내 코드 복사하기", style: .text) {
                store.send(.copyMyCodeButtonTapped)
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
            .padding(.horizontal, 20)
            .background(Color.gray0)
        }
    }
}

// MARK: - Popup
private extension FriendListView {
    @ViewBuilder
    private var popupSection: some View {
        if store.popup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                    .onTapGesture { store.send(.popup(.hide)) }

                ActionPopupView(
                    title: store.popup.title,
                    message: store.popup.message,
                    actionTitle: store.popup.actionTitle,
                    cancelTitle: store.popup.cancelTitle,
                    style: .destructive,
                    onAction: {
                        switch store.popup.action {
                        case let .deleteFriend(id):
                            store.send(.popup(.hide))
                            store.send(.confirmDelete(id))
                        default: break
                        }
                    },
                    onCancel: { store.send(.popup(.hide)) }
                )
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
}

// MARK: - Network Error Popup Section
private extension FriendListView {
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

