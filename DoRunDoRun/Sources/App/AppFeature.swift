import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var isLoggedIn = false
        
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
        // 앱 시작
        case appStarted
        case refreshTokenResponse(Bool) // refresh 결과 처리
        
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
            case .appStarted:
                // refreshToken 존재 시 → 자동 갱신 시도
                guard let refreshToken = TokenManager.shared.refreshToken,
                      !refreshToken.isEmpty else {
                    state.isLoggedIn = false
                    return .none
                }
                return .run { send in
                    let success = await TokenRefresher.shared.tryRefresh()
                    await send(.refreshTokenResponse(success))
                }
                
            case let .refreshTokenResponse(success):
                if success {
                    print("자동 로그인 성공 (토큰 갱신 완료)")
                    state.isLoggedIn = true
                } else {
                    print("자동 로그인 실패 → 온보딩 전환")
                    TokenManager.shared.clear()
                    state.isLoggedIn = false
                }
                return .none
                
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
