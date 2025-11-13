import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var splash = SplashFeature.State()
        var showSplash = true
        
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
        case splash(SplashFeature.Action)
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
        Scope(state: \.splash, action: \.splash) { SplashFeature() }
        Scope(state: \.onboarding, action: \.onboarding) { OnboardingFeature() }
        Scope(state: \.running, action: \.running) { RunningFeature() }
        Scope(state: \.feed, action: \.feed) { FeedFeature() }
        Scope(state: \.my, action: \.my) { MyFeature() }

        Reduce { state, action in
            switch action {
            case .splash(.splashTimeoutEnded):
                state.showSplash = false
                return .send(.appStarted)
                
            case .appStarted:
                guard let accessToken = TokenManager.shared.accessToken,
                      let refreshToken = TokenManager.shared.refreshToken,
                      !refreshToken.isEmpty else {
                    print("❌ 로그인 정보 없음 → 온보딩 전환")
                    state.isLoggedIn = false
                    return .none
                }

                // accessToken이 유효한지 검사
                if TokenRefresher.isAccessTokenValid(accessToken) {
                    print("✅ accessToken 유효 → 자동 로그인 유지")
                    state.isLoggedIn = true
                    return .none
                } else {
                    print("♻️ accessToken 만료 → refresh 요청 시작")
                    return .run { send in
                        let success = await TokenRefresher.shared.tryRefresh()
                        await send(.refreshTokenResponse(success))
                    }
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
                state.my.path.removeAll()
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
                // Running delegate: RunningDetail 뒤로가기 → Feed 탭 전환
            case .running(.delegate(.navigateToFeed)):
                state.selectedTab = .feed
                return .none
                
            // MARK: - Feed ↔ My 동기화
            case .feed(.delegate(.feedUpdateCompleted(let feedID, let newImageURL))):
                print("Feed에서 업데이트 발생 → My에서도 즉시 반영")
                if let index = state.my.feeds.firstIndex(where: { viewState in
                    if case let .feed(item) = viewState.kind {
                        return item.feedID == feedID
                    }
                    return false
                }) {
                    if case var .feed(item) = state.my.feeds[index].kind {
                        item.imageURL = newImageURL
                        state.my.feeds[index].kind = .feed(item)
                    }
                }
                return .none
                
            case let .feed(.delegate(.feedDeleteCompleted(feedID))):
                print("전체 피드에서도 내 피드 삭제 반영")
                MyFeature.removeFeedAndCleanupIfEmpty(feedID: feedID, from: &state.my.feeds)
                return .none
                
            // My에서 수정됨 → Feed에서도 반영
            case .my(.delegate(.feedUpdateCompleted(let feedID, let newImageURL))):
                print("My에서 수정 발생 → Feed에서도 반영")
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].imageURL = newImageURL
                }
                return .none
                
            // My에서 삭제됨 → Feed에서도 삭제
            case .my(.delegate(.feedDeleteCompleted(let feedID))):
                print("My에서 삭제 발생 → Feed에서도 반영")
                state.feed.feeds.removeAll { $0.feedID == feedID }
                return .none
                                
            case .my(.delegate(.logoutCompleted)),
                 .my(.delegate(.withdrawCompleted)):
                print("로그아웃 완료 → 온보딩 전환")
                state.isLoggedIn = false
                state.selectedTab = .running
                state.onboarding.path.removeAll()
                state.onboarding = OnboardingFeature.State()
                return .none
                
            default:
                return .none
            }
        }
    }
}
