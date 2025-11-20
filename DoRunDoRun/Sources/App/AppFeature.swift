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

        // 각 탭의 Navigation Path
        var feedPath = StackState<FeedPath.State>()
        var myPath = StackState<MyPath.State>()

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

        // Navigation Path
        case feedPath(StackActionOf<FeedPath>)
        case myPath(StackActionOf<MyPath>)
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
                state.myPath.removeAll()
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
                // Running delegate: RunningDetail 뒤로가기 → Feed 탭 전환
            case .running(.delegate(.navigateToFeed)):
                state.selectedTab = .feed
                return .none

            // Running delegate: 프로필 탭 → My 탭 전환
            case .running(.delegate(.navigateToMyProfile)):
                state.selectedTab = .my
                return .none

            // RunningReady delegate: Feed 동기화
            case .running(.ready(.delegate(.feedUpdateCompleted(let feedID, let newImageURL)))):
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].imageURL = newImageURL
                }
                return .send(.feed(.delegate(.feedUpdateCompleted(feedID: feedID, newImageURL: newImageURL))))

            case .running(.ready(.delegate(.feedDeleteCompleted(let feedID)))):
                state.feed.feeds.removeAll(where: { $0.feedID == feedID })
                return .send(.feed(.delegate(.feedDeleteCompleted(feedID: feedID))))
                
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

            // MARK: - FeedFeature Navigation Delegates
            case .feed(.delegate(.navigateToMyProfile)):
                // 본인 프로필 탭 시 Feed 탭 내에서 MyView로 navigation
                state.feedPath.append(.myProfile)
                return .none

            case .feed(.delegate(.navigateToFriendList)):
                state.feedPath.append(.friendList(FriendListFeature.State()))
                return .none

            case .feed(.delegate(.navigateToNotificationList)):
                state.feedPath.append(.notificationList(NotificationFeature.State()))
                return .none

            case let .feed(.delegate(.navigateToCertificationList(users))):
                state.feedPath.append(.certificationList(FeedCertificationListFeature.State(users: users)))
                return .none

            case let .feed(.delegate(.navigateToFriendProfile(userID))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none

            case let .feed(.delegate(.navigateToFeedDetail(feedID, feed))):
                state.feedPath.append(.feedDetail(MyFeedDetailFeature.State(feedId: feedID, feed: feed)))
                return .none

            case let .feed(.delegate(.navigateToEditFeed(feed))):
                state.feedPath.append(.editMyFeedDetail(EditMyFeedDetailFeature.State(feed: feed)))
                return .none

            case .feed(.delegate(.navigateToSelectSession)):
                state.feedPath.append(.selectSession(SelectSessionFeature.State()))
                return .none

            case .feed(.delegate(.navigateBack)):
                state.feedPath.removeLast()
                return .none

            // MARK: - MyFeature Navigation Delegates
            case let .my(.delegate(.navigateToFeedDetail(feedID, feed))):
                // feedPath에 myProfile이 있으면 feedPath에 append, 아니면 myPath에 append
                if state.feedPath.last?.is(\.myProfile) == true {
                    state.feedPath.append(.feedDetail(MyFeedDetailFeature.State(feedId: feedID, feed: feed)))
                } else {
                    state.myPath.append(.myFeedDetail(MyFeedDetailFeature.State(feedId: feedID, feed: feed)))
                }
                return .none

            case let .my(.delegate(.navigateToSessionDetail(session, sessionId))):
                // feedPath에 myProfile이 있으면 feedPath에 append, 아니면 myPath에 append
                if state.feedPath.last?.is(\.myProfile) == true {
                    state.feedPath.append(.mySessionDetail(MySessionDetailFeature.State(session: session, sessionId: sessionId)))
                } else {
                    state.myPath.append(.mySessionDetail(MySessionDetailFeature.State(session: session, sessionId: sessionId)))
                }
                return .none

            case .my(.delegate(.navigateToSetting)):
                state.myPath.append(.setting(SettingFeature.State()))
                return .none

            case .my(.delegate(.navigateBack)):
                // feedPath에 myProfile이 있으면 feedPath에서 제거, 아니면 myPath에서 제거
                if state.feedPath.last?.is(\.myProfile) == true {
                    state.feedPath.removeLast()
                } else {
                    state.myPath.removeLast()
                }
                return .none

            // MARK: - Path Element Delegates (Feed Path)
            case .feedPath(.element(id: _, action: .friendList(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case let .feedPath(.element(id: _, action: .friendList(.delegate(.navigateToFriendProfile(userID))))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none

            case .feedPath(.element(id: _, action: .friendList(.delegate(.navigateToMyProfile)))):
                state.feedPath.append(.myProfile)
                return .none

            case .feedPath(.element(id: _, action: .notificationList(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case .feedPath(.element(id: _, action: .certificationList(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case let .feedPath(.element(id: _, action: .certificationList(.delegate(.navigateToFriendProfile(userID))))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none

            case .feedPath(.element(id: _, action: .certificationList(.delegate(.navigateToMyProfile)))):
                state.feedPath.append(.myProfile)
                return .none

            case .feedPath(.element(id: _, action: .friendProfile(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.feedUpdated(feedID, imageURL))))):
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].imageURL = imageURL
                }
                return .send(.feed(.delegate(.feedUpdateCompleted(feedID: feedID, newImageURL: imageURL))))

            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.feedDeleted(feedID))))):
                state.feed.feeds.removeAll(where: { $0.feedID == feedID })
                return .send(.feed(.delegate(.feedDeleteCompleted(feedID: feedID))))

            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.reactionUpdated(feedID, reactions))))):
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].reactions = reactions
                }
                return .none

            case .feedPath(.element(id: _, action: .feedDetail(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.navigateToFriendProfile(userID))))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none

            case .feedPath(.element(id: _, action: .feedDetail(.delegate(.navigateToMyProfile)))):
                // feedPath에 이미 myProfile이 있으면 feedDetail만 dismiss, 없으면 myProfile append
                if state.feedPath.contains(where: { $0.is(\.myProfile) }) {
                    state.feedPath.removeLast()
                } else {
                    state.feedPath.append(.myProfile)
                }
                return .none

            case let .feedPath(.element(id: _, action: .editMyFeedDetail(.delegate(.updateCompleted(feedID, imageURL))))):
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].imageURL = imageURL
                }
                return .send(.feed(.delegate(.feedUpdateCompleted(feedID: feedID, newImageURL: imageURL))))

            case .feedPath(.element(id: _, action: .editMyFeedDetail(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case .feedPath(.element(id: _, action: .selectSession(.delegate(.feedUploadCompleted)))):
                state.feedPath.removeLast()
                return .send(.feed(.fetchSelfieFeeds(page: 0)))

            case .feedPath(.element(id: _, action: .selectSession(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case .feedPath(.element(id: _, action: .mySessionDetail(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            case .feedPath(.element(id: _, action: .mySessionDetail(.delegate(.navigateToMyProfile)))):
                // feedPath의 세션 상세에서 인증 게시물을 보고 내 프로필을 선택한 경우 - 세션 상세 화면 dismiss
                state.feedPath.removeLast()
                return .none

            // MARK: - Path Element Delegates (My Path)
            case let .myPath(.element(id: _, action: .myFeedDetail(.delegate(.feedUpdated(feedID, imageURL))))):
                if let index = state.my.feeds.firstIndex(where: {
                    if case let .feed(item) = $0.kind {
                        return item.feedID == feedID
                    }
                    return false
                }) {
                    if case let .feed(item) = state.my.feeds[index].kind {
                        var updatedFeed = item
                        updatedFeed.imageURL = imageURL
                        state.my.feeds[index] = .init(id: state.my.feeds[index].id, kind: .feed(updatedFeed))
                    }
                }
                return .send(.my(.delegate(.feedUpdateCompleted(feedID: feedID, newImageURL: imageURL))))

            case let .myPath(.element(id: _, action: .myFeedDetail(.delegate(.feedDeleted(feedID))))):
                MyFeature.removeFeedAndCleanupIfEmpty(feedID: feedID, from: &state.my.feeds)
                return .send(.my(.delegate(.feedDeleteCompleted(feedID: feedID))))

            case .myPath(.element(id: _, action: .myFeedDetail(.backButtonTapped))):
                state.myPath.removeLast()
                return .none

            case let .myPath(.element(id: _, action: .myFeedDetail(.delegate(.navigateToFriendProfile(userID))))):
                state.myPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none

            case .myPath(.element(id: _, action: .myFeedDetail(.delegate(.navigateToMyProfile)))):
                // My 탭에서 본인을 탭한 경우 - 피드 상세 화면 dismiss
                state.myPath.removeLast()
                return .none

            case .myPath(.element(id: _, action: .mySessionDetail(.backButtonTapped))):
                state.myPath.removeLast()
                return .none

            case .myPath(.element(id: _, action: .mySessionDetail(.delegate(.navigateToMyProfile)))):
                // 세션 상세에서 인증 게시물을 보고 내 프로필을 선택한 경우 - 세션 상세 화면 dismiss
                state.myPath.removeLast()
                return .none

            case .myPath(.element(id: _, action: .setting(.delegate(.logoutCompleted)))):
                return .send(.my(.delegate(.logoutCompleted)))

            case .myPath(.element(id: _, action: .setting(.delegate(.withdrawCompleted)))):
                return .send(.my(.delegate(.withdrawCompleted)))

            case .myPath(.element(id: _, action: .setting(.backButtonTapped))):
                state.myPath.removeLast()
                return .none

            case .myPath(.element(id: _, action: .friendProfile(.backButtonTapped))):
                state.myPath.removeLast()
                return .none

            default:
                return .none
            }
        }
        .forEach(\.feedPath, action: \.feedPath)
        .forEach(\.myPath, action: \.myPath)
    }

    // MARK: - Path Reducers
    @Reducer
    enum FeedPath {
        case friendList(FriendListFeature)
        case notificationList(NotificationFeature)
        case certificationList(FeedCertificationListFeature)
        case friendProfile(FriendProfileFeature)
        case myProfile  // 본인 프로필 (MyFeature 공유)
        case feedDetail(MyFeedDetailFeature)
        case editMyFeedDetail(EditMyFeedDetailFeature)
        case selectSession(SelectSessionFeature)
        case mySessionDetail(MySessionDetailFeature)
    }

    @Reducer
    enum MyPath {
        case myFeedDetail(MyFeedDetailFeature)
        case mySessionDetail(MySessionDetailFeature)
        case setting(SettingFeature)
        case friendProfile(FriendProfileFeature)
    }
}
