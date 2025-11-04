import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithPerceptionTracking {
            if store.isLoggedIn {
                // 로그인 후 메인 탭 화면
                MainTabView(store: store)
                    .transition(.opacity.combined(with: .scale))
                    .id("main") // 루트 리셋용 ID
            } else {
                // 로그인 전 온보딩 화면
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
                .transition(.opacity)
                .id("onboarding")
            }
        }
    }
}

struct MainTabView: View {
    @Perception.Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                    RunningView(store: store.scope(state: \.running, action: \.running))
                        .tabItem { Label("러닝", systemImage: "figure.run") }
                        .tag(AppFeature.State.Tab.running)
                    
                    FeedView(store: store.scope(state: \.feed, action: \.feed))
                        .tabItem { Label("피드", systemImage: "list.bullet.rectangle") }
                        .tag(AppFeature.State.Tab.feed)
                    
                    MyView(store: store.scope(state: \.my, action: \.my))
                        .tabItem { Label("마이", systemImage: "person.circle") }
                        .tag(AppFeature.State.Tab.my)
                }
            }
        }
    }
}
