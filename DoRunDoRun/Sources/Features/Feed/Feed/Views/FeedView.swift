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
                popupSection
                networkErrorPopupSection
            }
            // 시트 표시 상태 변화 감지
            .onChange(of: store.isReactionDetailPresented || store.isReactionPickerPresented) { isSheetVisible in
                if isSheetVisible {
                    // UIKit overlay를 윈도우 최상단에 표시
                    UIApplication.presentOverlay {
                        ZStack(alignment: .bottom) {
                            // DIM 배경
                            Color.dimLight
                                .ignoresSafeArea()
                                .onTapGesture { store.send(.dismissSheet) }
                                .transition(.opacity)
                            
                            // 리액션 상세 시트
                            if store.isReactionDetailPresented {
                                ReactionDetailSheetView(
                                    store: store.scope(state: \.reactionDetail, action: \.reactionDetail)
                                )
                                .transition(.move(edge: .bottom))
                            }
                            
                            // 리액션 추가 시트
                            if store.isReactionPickerPresented {
                                ReactionPickerSheetView(
                                    store: store.scope(state: \.reactionPicker, action: \.reactionPicker)
                                )
                                .transition(.move(edge: .bottom))
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: isSheetVisible)
                    }
                } else {
                    UIApplication.dismissOverlay()
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
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(spacing: 0) {
                headerSection
                if store.feeds.isEmpty {
                    VStack(spacing: 0) {
                        scrollHeaderSection
                        FeedEmptyView()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            scrollHeaderSection
                            feedListSection
                        }
                    }
                }
            }
            .onAppear { store.send(.onAppear) }
            // Navigation destinations
            .navigationDestination(
                item: $store.scope(state: \.selectSession, action: \.selectSession)
            ) { store in
                SelectSessionView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.editMyFeedDetail, action: \.editMyFeedDetail)
            ) { store in
                EditMyFeedDetailView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.certificationList, action: \.certificationList)
            ) { store in
                FeedCertificationListView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.friendList, action: \.friendList)
            ) { store in
                FriendListView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.notificationList, action: \.notificationList)
            ) { store in
                NotificationView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.myFeedDetail, action: \.myFeedDetail)
            ) { store in
                MyFeedDetailView(store: store)
            }

        }
    }

    /// Header Section
    var headerSection: some View {
        HStack {
            TypographyText(text: "인증피드", style: .t1_700)
            Spacer()
            HStack(spacing: 12) {
                Button(action: { store.send(.friendListButtonTapped) }) {
                    Image(.friends, fill: .fill, size: .medium)
                }
                Button { store.send(.notificationButtonTapped) } label: {
                    Image(.alarmActive, size: .medium)
                }            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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
                    onReportTapped: { store.send(.showReportPopup(feed.feedID)) }
                )
                .onTapGesture {
                    store.send(.showFeedDetail(feed))
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
    var floatingUploadButtonSection: some View {
        HStack {
            Spacer()
            Button {
                store.send(.uploadButtonTapped)
            } label: {
                Image(.add, size: .medium)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray0)
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .fill(Color.blue600)
                            .shadow(
                                color: Color.gray900.opacity(0.15),
                                radius: 12,
                                x: 0,
                                y: 2
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                   value: store.isReactionDetailPresented || store.isReactionPickerPresented)
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
