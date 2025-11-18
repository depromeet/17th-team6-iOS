import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithPerceptionTracking {
            if store.showSplash {
                SplashView(store: store.scope(state: \.splash, action: \.splash))
                    .transition(.opacity.combined(with: .scale))
                    .id("splash")
            } else if store.isLoggedIn {
                MainTabView(store: store)
                    .transition(.opacity.combined(with: .scale))
                    .id("main")
            } else {
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
                .transition(.opacity.combined(with: .scale))
                .id("onboarding")
            }
        }
        .task {
            store.send(.appStarted)   // 앱 시작 시 자동 로그인 검사
        }
    }
}


struct MainTabView: View {
    @Perception.Bindable var store: StoreOf<AppFeature>

    var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                RunningView(store: store.scope(state: \.running, action: \.running))
                    .tabItem {
                        VStack {
                            Image(.running, fill: .fill, size: .medium)
                                .renderingMode(.template)
                            Text("러닝")
                        }
                    }
                    .tag(AppFeature.State.Tab.running)

                NavigationStack(path: $store.scope(state: \.feedPath, action: \.feedPath)) {
                    FeedView(store: store.scope(state: \.feed, action: \.feed))
                } destination: { pathStore in
                    switch pathStore.case {
                    case .friendList(let store): FriendListView(store: store)
                    case .notificationList(let store): NotificationView(store: store)
                    case .certificationList(let store): FeedCertificationListView(store: store)
                    case .friendProfile(let store): FriendProfileView(store: store)
                    case .myProfile:
                        // 본인 프로필: AppFeature의 MyFeature state 공유
                        MyView(
                            store: self.store.scope(state: \.my, action: \.my),
                            hideNavigationTitle: true  // Feed에서 진입 시 타이틀 숨김
                        )
                    case .feedDetail(let store): MyFeedDetailView(store: store)
                    case .editMyFeedDetail(let store): EditMyFeedDetailView(store: store)
                    case .selectSession(let store): SelectSessionView(store: store)
                    }
                }
                .tabItem {
                    VStack {
                        Image(.feed, fill: .fill, size: .medium)
                            .renderingMode(.template)
                        Text("인증피드")
                    }
                }
                .tag(AppFeature.State.Tab.feed)

                NavigationStack(path: $store.scope(state: \.myPath, action: \.myPath)) {
                    MyView(store: store.scope(state: \.my, action: \.my))
                } destination: { store in
                    switch store.case {
                    case .myFeedDetail(let store): MyFeedDetailView(store: store)
                    case .mySessionDetail(let store): MySessionDetailView(store: store)
                    case .setting(let store): SettingView(store: store)
                    }
                }
                .tabItem {
                    VStack {
                        Image(.profile, fill: .fill, size: .medium)
                            .renderingMode(.template)
                        Text("마이")
                    }
                }
                .tag(AppFeature.State.Tab.my)
            }
            .tint(Color.gray900)
        }
    }
}
