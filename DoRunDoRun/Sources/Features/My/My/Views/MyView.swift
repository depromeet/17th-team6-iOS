import SwiftUI
import ComposableArchitecture

struct MyView: View {
    @Perception.Bindable var store: StoreOf<MyFeature>
    var hideNavigationTitle: Bool = false  // Feed에서 진입 시 true

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
            .onAppear { store.send(.onAppear) }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                // 왼쪽: 타이포그라피 (Feed에서 진입 시 숨김)
                if !hideNavigationTitle {
                    ToolbarItem(placement: .navigationBarLeading) {
                        TypographyText(text: "마이", style: .t1_700, color: .gray900)
                            .allowsHitTesting(false)  // 터치 비활성화로 배경 제거
                    }
                }
                // 오른쪽: 설정 버튼
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.settingButtonTapped)
                    } label: {
                        Image(.setting, fill: .fill, size: .medium)
                    }
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
                profileSection
                tabHeaderSection
                tabContentSection
            }
        }
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
