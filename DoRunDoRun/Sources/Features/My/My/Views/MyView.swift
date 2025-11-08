import SwiftUI
import ComposableArchitecture

struct MyView: View {
    @Perception.Bindable var store: StoreOf<MyFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ZStack(alignment: .bottom) {
                    serverErrorSection
                    mainSection
                    networkErrorPopupSection
                }
            } destination: { store in
                switch store.case {
                case .myFeedDetail(let store): MyFeedDetailView(store: store)
                case .runningDetail(let store): RunningDetailView(store: store)
                case .setting(let store): SettingView(store: store)
                }
            }
        }
    }
}

// MARK: - Server Error Section
private extension MyView {
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
private extension MyView {
    /// Main Section
    @ViewBuilder
    private var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(spacing: 0) {
                navigationSection
                profileSection
                tabHeaderSection
                tabContentSection
            }
            .onAppear { store.send(.onAppear) }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    /// 네비게이션 섹션
    private var navigationSection: some View {
        HStack {
            TypographyText(text: "마이", style: .t1_700, color: .gray900)
            Spacer()
            Button {
                store.send(.settingButtonTapped)
            } label: {
                Image(.setting, fill: .fill, size: .medium)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
    }

    /// 프로필 섹션
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                ProfileImageView(
                    image: Image(.profilePlaceholder),
                    imageURL: store.userSummary?.profileImageURL,
                    style: .plain,
                    isZZZ: false
                )

                VStack(alignment: .leading, spacing: 2) {
                    if let userSummary = store.userSummary {
                        TypographyText(text: userSummary.name, style: .t2_700, color: .gray900)
                        TypographyText(text: "친구 \(userSummary.friendCountText)", style: .b2_500, color: .gray700)
                    }
                }

                Spacer()
            }
            HStack {
                if let userSummary = store.userSummary {
                    HStack(alignment: .center, spacing: 12) {
                        TypographyText(text: "누적 거리", style: .b2_500, color: .gray500)
                        TypographyText(text: userSummary.totalDistanceText, style: .t2_700, color: .gray900)
                    }
                    Spacer()
                    HStack(alignment: .center, spacing: 12) {
                        TypographyText(text: "인증 횟수", style: .b2_500, color: .gray500)
                        TypographyText(text: userSummary.selfieCountText, style: .t2_700, color: .gray900)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 26)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    /// 탭 헤더 섹션
    private var tabHeaderSection: some View {
        HStack {
            tabButton(title: "인증", index: MyFeature.State.Tab.feed.rawValue)
            tabButton(title: "기록", index: MyFeature.State.Tab.session.rawValue)
        }
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.gray100),
            alignment: .bottom
        )
    }
    
    /// 탭 버튼
    private func tabButton(title: String, index: Int) -> some View {
        Button {
            store.send(index == 0 ? .feedTapped : .sessionTapped)
        } label: {
            VStack(spacing: 0) {
                TypographyText(text: title, style: .t2_700, color: store.currentTap == index ? .gray800 : .gray300)
                .padding(.top, 9)
                .padding(.bottom, 7)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(store.currentTap == index ? Color.gray800 : .clear)
            }
            .frame(maxWidth: .infinity)
        }
    }

    /// 탭 컨텐츠 섹션
    private var tabContentSection: some View {
        TabView(selection: $store.currentTap.sending(\.pageChanged)) {
            Group {
                if store.feeds.isEmpty {
                    MyFeedEmptyView()
                } else {
                    MyFeedView(
                        feeds: store.feeds,
                        loadNextPageIfNeeded: { feed in
                            store.send(.loadNextPageIfNeeded(currentItem: feed))
                        },
                        isLoading: store.isLoading,
                        onFeedTap: { feed in
                            store.send(.feedItemTapped(feed))
                        }
                    )
                }
            }
            .tag(MyFeature.State.Tab.feed.rawValue)
            
            VStack(spacing: 0) {
                 MonthNavigationHeaderView(
                     monthTitle: store.monthTitle,
                     onPreviousTapped: { store.send(.previousMonthTapped) },
                     onNextTapped: { store.send(.nextMonthTapped) }
                 )

                 if store.filteredSessions.isEmpty {
                     MySessionEmptyView()
                 } else {
                     MySessionView(
                         sessions: store.filteredSessions,
                         onSessionTap: { session in
                             store.send(.sessionCardTapped(session))
                         }
                     )
                 }
             }
             .tag(MyFeature.State.Tab.session.rawValue)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: store.currentTap)
    }
}

// MARK: - Network Error Popup Section
private extension MyView {
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
    MyView(
        store: Store(initialState: MyFeature.State()) {
            MyFeature()
        }
    )
}
