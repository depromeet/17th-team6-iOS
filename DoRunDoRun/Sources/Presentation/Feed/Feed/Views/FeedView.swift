import SwiftUI
import ComposableArchitecture

struct FeedView: View {
    @Perception.Bindable var store: StoreOf<FeedFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                floatingUploadButtonSection
                toastSection
                popupSection
                networkErrorPopupSection
            }
            .onAppear { store.send(.onAppear) }
            .onChange(of: store.isReactionDetailPresented || store.isReactionPickerPresented) { visible in
                if visible {
                    UIApplication.presentOverlay(
                        dim: {
                            Color.dimLight
                                .ignoresSafeArea()
                                .onTapGesture { store.send(.dismissSheet) }
                        },
                        sheet: {
                            ZStack(alignment: .bottom) {
                                Color.clear
                                    .ignoresSafeArea()
                                    .contentShape(Rectangle())
                                    .onTapGesture { store.send(.dismissSheet) }

                                if store.isReactionDetailPresented {
                                    ReactionDetailSheetView(
                                        store: store.scope(state: \.reactionDetail, action: \.reactionDetail)
                                    )
                                }
                                if store.isReactionPickerPresented {
                                    ReactionPickerSheetView(
                                        store: store.scope(state: \.reactionPicker, action: \.reactionPicker)
                                    )
                                }
                            }
                        }
                    )
                } else {
                    UIApplication.dismissOverlay()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                // 왼쪽: 타이포그라피 유지
                ToolbarItem(placement: .navigationBarLeading) {
                    TypographyText(text: "인증피드", style: .t1_700, color: .gray900)
                        .allowsHitTesting(false)  // 터치 비활성화로 배경 제거
                }
                // 오른쪽: 친구 리스트, 알림 버튼
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { store.send(.friendListButtonTapped) }) {
                            Image(.friends, fill: .fill, size: .medium)
                        }
                        Button { store.send(.notificationButtonTapped) } label: {
                            Image(
                                store.unreadCount > 0 ? .alarmActive : .alarm,
                                fill: .fill,
                                size: .medium
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Server Error Section
private extension FeedView {
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
private extension FeedView {
    /// Main Section
    var mainSection: some View {
        Group {
            if store.serverError.serverErrorType == nil {
                if store.feeds.isEmpty {
                    VStack(spacing: 0) {
                        scrollHeaderSection
                        FeedEmptyView()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            scrollHeaderSection
                            feedListSection
                        }
                    }
                }
            }
        }
    }

    /// Scroll Header
    var scrollHeaderSection: some View {
        VStack(spacing: 0) {
            weakCalendarSection

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.gray50)
                .padding(.vertical, 24)

            feedCertificationSummarySection
                .padding(.bottom, 16)
        }
    }

    /// Week Calendar
    var weakCalendarSection: some View {
        WeekCalendarView(
            weekDates: store.weekDates,
            selectedDate: store.selectedDate,
            weekCounts: store.weekCounts,
            onSelect: { store.send(.selectDate($0)) },
            onWeekChange: { store.send(.changeWeek($0)) }
        )
    }

    ///Feed Certification Summary
    @ViewBuilder
    var feedCertificationSummarySection: some View {
        if !store.selfieUsers.isEmpty {
            FeedCertificationSummaryView(
                totalCount: store.selfieUsers.count,
                profileImageURLs: store.selfieUsers.map { $0.profileImageUrl },
                isMyIncluded: store.selfieUsers.contains(where: { $0.isMe })
            )
            .onTapGesture {
                store.send(.certificationSummaryTapped)
            }
        } else {
            Color.clear.frame(height: 25)
        }
    }

    /// Feed List
    @ViewBuilder
    var feedListSection: some View {
        LazyVStack(spacing: 40) {
            ForEach(store.feeds, id: \.feedID) { feed in
                WithPerceptionTracking {
                    FeedItemView(
                        feed: feed,
                        displayedReactions: store.state.displayedReactions(for: feed),
                        hiddenReactions: store.state.hiddenReactions(for: feed),
                        extraReactionCount: store.state.extraReactionCount(for: feed),
                        onTapReaction: { store.send(.reactionTapped(feedID: feed.feedID, reaction: $0)) },
                        onLongPressReaction: { store.send(.reactionLongPressed(feedID: feed.feedID, reaction: $0)) },
                        onTapAddReaction: { store.send(.addReactionTapped(feedID: feed.feedID)) },
                        onEditTapped: { store.send(.editButtonTapped(feedID: feed.feedID)) },
                        onDeleteTapped: { store.send(.showDeletePopup(feed.feedID)) },
                        onSaveImageTapped: { store.send(.saveImageButtonTapped(feed: feed)) },
                        onReportTapped: { store.send(.showReportPopup(feed.feedID)) },
                        onImageTapped: { store.send(.feedImageTapped(feed)) },
                        onProfileTapped: { store.send(.feedProfileTapped(feed: feed)) }
                    )
                }
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 102)
    }
}

// MARK: - Floating Upload Button Section
private extension FeedView {
    /// Floating Upload Button Section
    private var floatingUploadButtonSection: some View {
        ZStack {
            // 배경 dim
            if store.isFabExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.send(.dismissFab)
                    }
                    .transition(.opacity)
            }

            VStack(alignment: .trailing, spacing: 12) {
                if store.isFabExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        fabActionButton(
                            title: "기록 불러오기",
                        ) {
                            store.send(.entryMenuSelectSessionTapped)
                        }
                        
                        fabActionButton(
                            title: "직접 기록 입력하기",
                        ) {
                            store.send(.entryMenuEnterManualSessionTapped)
                        }

                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray0)
                    )
                }

                // 메인 FAB
                Button {
                    store.send(.fabTapped)
                } label: {
                    Image(.add, size: .medium)
                        .renderingMode(.template)
                        .foregroundColor(store.isFabExpanded ? Color.gray600 : Color.gray0)
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(store.isFabExpanded ? Color.gray0 : Color.blue600))
                        .shadow(radius: 8)
                        .rotationEffect(.degrees(store.isFabExpanded ? 45 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7),
                                   value: store.isFabExpanded)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }
    
    private func fabActionButton(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 0) {
                TypographyText(text: title, style: .b1_500, color: .gray700)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

// MARK: - Toast Section
private extension FeedView {
    @ViewBuilder
    private var toastSection: some View {
        if store.toast.isVisible {
            ActionToastView(
                message: store.toast.message,
                icon: Image(.checkCircle, fill: .fill, size: .medium),
                iconColor: .blue200
            )
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.3), value: store.toast.isVisible)
        }
    }
}

// MARK: - Popup Section
private extension FeedView {
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
                        case let .deleteFeed(feedID):
                            store.send(.popup(.hide))
                            store.send(.confirmDelete(feedID))
                        case let .reportFeed(feedID):
                            store.send(.popup(.hide))
                            store.send(.confirmReport(feedID))
                        default:
                            break
                        }
                    },
                    onCancel: { store.send(.popup(.hide)) }
                )
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(20)
        }
    }
}

// MARK: - Network Error Popup Section
private extension FeedView {
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

// MARK: - Preview
#Preview {
    FeedView(
        store: Store(
            initialState: FeedFeature.State(
                feeds: []
            ),
            reducer: { FeedFeature() }
        )
    )
}
