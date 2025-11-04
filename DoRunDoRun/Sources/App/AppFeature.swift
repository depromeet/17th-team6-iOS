import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var isLoggedIn = true
        // 로그인 전
        var onboarding = OnboardingFeature.State()
        
        // 로그인 후
        var running = RunningFeature.State()
        var feed = FeedFeature.State()
        var my = MyFeature.State()
        var selectedTab: Tab = .running
        enum Tab: Hashable { case running, feed, my }
    }

    enum Action {
        // 로그인 전
        case onboarding(OnboardingFeature.Action)
        
        // 로그인 후
        case tabSelected(State.Tab)
        case running(RunningFeature.Action)
        case feed(FeedFeature.Action)
        case my(MyFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) { OnboardingFeature() }
        Scope(state: \.running, action: \.running) { RunningFeature() }
        Scope(state: \.feed, action: \.feed) { FeedFeature() }
        Scope(state: \.my, action: \.my) { MyFeature() }

        Reduce { state, action in
            switch action {
            case .onboarding(.finished):
                // 온보딩 완료 → 메인 탭으로 전환
                state.isLoggedIn = true
                return .none
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .running, .feed, .my:
                return .none
            default:
                return .none
            }
        }
    }
}
