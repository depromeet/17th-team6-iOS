import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var shouldShowInterstitialAd = false
        enum AdSource { case feedSelectSession, runningDetail, sessionDetailFeed, sessionDetailMy }
        var adSource: AdSource?

        var splash = SplashFeature.State()
        var showSplash = true
        
        var isLoggedIn = false
        
        // 로그인 전
        var onboarding = OnboardingFeature.State()
        
        // 로그인 후
        var running = RunningFeature.State()
        var feed = FeedFeature.State()
        var my = MyProfileFeature.State()
        var selectedTab: Tab = .running
        enum Tab: Hashable { case running, feed, my }

        // MARK: - Navigation Paths
        // 각 탭은 독립적인 navigation stack을 가지며, 탭 전환 시에도 각자의 stack 유지

        /// Running 탭의 navigation stack
        /// 포함 화면: 친구 목록, 친구 프로필, 내 프로필
        var runningPath = StackState<RunningPath.State>()

        /// Feed 탭의 navigation stack
        /// 포함 화면: 친구 목록, 알림 목록, 인증 목록, 친구/내 프로필, 피드 상세, 피드 수정, 세션 선택, 세션 상세
        var feedPath = StackState<FeedPath.State>()

        /// My 탭의 navigation stack
        /// 포함 화면: 피드 상세, 세션 상세, 설정, 친구 프로필
        /// 특이사항: Feed 탭에서 내 프로필(myProfile) 진입 시에는 feedPath를 사용
        var myPath = StackState<MyPath.State>()
    }

    enum Action {
        case interstitialAdShown

        case splash(SplashFeature.Action)
        case appStarted
        case refreshTokenResponse(Bool) // refresh 결과 처리

        // 로그인 전
        case onboarding(OnboardingFeature.Action)

        // 로그인 후
        case tabSelected(State.Tab)
        case running(RunningFeature.Action)
        case feed(FeedFeature.Action)
        case my(MyProfileFeature.Action)

        // Navigation Path
        case runningPath(StackActionOf<RunningPath>)
        case feedPath(StackActionOf<FeedPath>)
        case myPath(StackActionOf<MyPath>)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.splash, action: \.splash) { SplashFeature() }
        Scope(state: \.onboarding, action: \.onboarding) { OnboardingFeature() }
        Scope(state: \.running, action: \.running) { RunningFeature() }
        Scope(state: \.feed, action: \.feed) { FeedFeature() }
        Scope(state: \.my, action: \.my) { MyProfileFeature() }

        Reduce { state, action in
            switch action {
            case .interstitialAdShown:
                state.shouldShowInterstitialAd = false
                let source = state.adSource
                state.adSource = nil

                switch source {
                case .feedSelectSession:
                    state.feedPath.removeLast()
                    return .send(.feed(.fetchSelfieFeeds(page: 0)))
                case .runningDetail:
                    state.selectedTab = .feed
                    return .send(.feed(.fetchSelfieFeeds(page: 0)))
                case .sessionDetailFeed:
                    state.feedPath.removeLast()
                    state.selectedTab = .feed
                    return .send(.feed(.fetchSelfieFeeds(page: 0)))
                case .sessionDetailMy:
                    state.myPath.removeLast()
                    state.selectedTab = .feed
                    return .send(.feed(.fetchSelfieFeeds(page: 0)))
                case .none:
                    return .send(.feed(.fetchSelfieFeeds(page: 0)))
                }

            case .splash(.splashTimeoutEnded):
                state.showSplash = false
                return .send(.appStarted)
                
            case .appStarted:
                // 1. 저장된 토큰이 있는지 검사
                guard let accessToken = TokenManager.shared.accessToken,
                      let refreshToken = TokenManager.shared.refreshToken,
                      !refreshToken.isEmpty else {
                    print("❌ 로그인 정보 없음 → 온보딩 전환")
                    state.isLoggedIn = false
                    return .none
                }

                // 2. accessToken이 유효한지 검사
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
                
            // 온보딩 완료 → 메인 탭으로 전환
            case .onboarding(.finished):
                state.isLoggedIn = true
                state.myPath.removeAll()
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            // MARK: - RunningFeature Navigation Delegates
                
            // RunningReady에서 친구 목록 탭 시 친구 목록으로 이동
            case .running(.delegate(.navigateToFriendList)):
                state.runningPath.append(.friendList(FriendListFeature.State()))
                return .none
                
            // RunningReady → FriendList에서 친구 프로필 탭 시 친구 프로필로 이동
            case .running(.delegate(.navigateToFriendProfile(let userID))):
                state.runningPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none
                
            // RunningReady에서 뒤로가기
            case .running(.delegate(.navigateBack)):
                state.runningPath.removeLast()
                return .none
                
            // RunningDetail에서 뒤로가기 : Feed 탭 전환
            case .running(.delegate(.navigateToFeed)):
                state.selectedTab = .feed
                return .none

            // RunningDetail에서 피드 업로드 완료 → 광고 표시
            case .running(.delegate(.feedUploadCompleted)):
                state.shouldShowInterstitialAd = true
                state.adSource = .runningDetail
                return .none

            // MARK: - Feed ↔ My 동기화
            case .feed(.delegate(.feedUpdateCompleted(let feedID, let newImageURL))):
                print("Feed에서 수정 발생 → My에서도 즉시 반영")
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
                print("Feed에서 삭제 발생 → My에서도 즉시 반영")
                MyProfileFeature.removeFeedAndCleanupIfEmpty(feedID: feedID, from: &state.my.feeds)
                return .none
                
            case .my(.delegate(.feedUpdateCompleted(let feedID, let newImageURL))):
                print("My에서 수정 발생 → Feed에서도 반영")
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].imageURL = newImageURL
                }
                return .none
                
            case .my(.delegate(.feedDeleteCompleted(let feedID))):
                print("My에서 삭제 발생 → Feed에서도 반영")
                state.feed.feeds.removeAll { $0.feedID == feedID }
                return .none

            // MARK: - FeedFeature Navigation Delegates

            // 친구 목록으로 이동 (네비게이션 영역에 친구 아이콘 탭 시)
            case .feed(.delegate(.navigateToFriendList)):
                state.feedPath.append(.friendList(FriendListFeature.State()))
                return .none

            // 알림 목록으로 이동 (네비게이션 영역에 알림 아이콘 탭 시)
            case .feed(.delegate(.navigateToNotificationList)):
                state.feedPath.append(.notificationList(NotificationListFeature.State()))
                return .none

            // 인증 유저 목록으로 이동 (오늘 인증한 유저 영역 탭 시)
            case let .feed(.delegate(.navigateToCertificationUserList(users))):
                state.feedPath.append(.certificationUserList(CertificationUserListFeature.State(users: users)))
                return .none
                
            // 내 프로필로 이동 (피드의 본인 프로필 탭 시)
            case .feed(.delegate(.navigateToMyProfile)):
                state.feedPath.append(.myProfile)
                return .none

            // 친구 프로필로 이동 (피드의 친구 프로필 탭 시)
            case let .feed(.delegate(.navigateToFriendProfile(userID))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none
                
            // 피드 상세로 이동 (피드 이미지 탭 시)
            case let .feed(.delegate(.navigateToFeedDetail(feedID, feed))):
                state.feedPath.append(.feedDetail(FeedDetailFeature.State(feedId: feedID, feed: feed)))
                return .none

            // 내 피드 수정하기로 이동 (본인 피드의 수정하기 버튼 탭 시)
            case let .feed(.delegate(.navigateToEditFeed(feed))):
                state.feedPath.append(.editMyFeedDetail(EditFeedDetailFeature.State(feed: feed)))
                return .none

            // 세션 선택으로 이동 (플로팅 버튼 탭 시)
            case .feed(.delegate(.navigateToSelectSession)):
                state.feedPath.append(.selectSession(SelectSessionFeature.State()))
                return .none
                
            // 직접 기록 입력 (플로팅 버튼 탭 시)
            case .feed(.delegate(.navigateToEnterManualSession)):
                state.feedPath.append(.enterManualSession(EnterManualSessionFeature.State()))
                return .none


            // 뒤로가기
            case .feed(.delegate(.navigateBack)):
                state.feedPath.removeLast()
                return .none

            // MARK: - MyProfileFeature Navigation Delegates
            // My 화면은 두 가지 경로로 진입 가능:
            // 1. My 탭에서 직접 진입 → myPath 사용
            // 2. Feed 탭에서 myProfile을 통해 진입 → feedPath 사용
            // 이를 구분하여 올바른 path에 화면을 push/pop

            // 피드 상세로 이동
            case let .my(.delegate(.navigateToFeedDetail(feedID, feed))):
                // Feed 탭 경로인지 My 탭 경로인지에 따라 다른 path 사용
                if state.feedPath.last?.is(\.myProfile) == true {
                    // Feed → myProfile → feedDetail
                    state.feedPath.append(.feedDetail(FeedDetailFeature.State(feedId: feedID, feed: feed)))
                } else {
                    // My → myFeedDetail
                    state.myPath.append(.myFeedDetail(FeedDetailFeature.State(feedId: feedID, feed: feed)))
                }
                return .none

            // 세션 상세로 이동
            case let .my(.delegate(.navigateToSessionDetail(session, sessionId))):
                // Feed 탭 경로인지 My 탭 경로인지에 따라 다른 path 사용
                if state.feedPath.last?.is(\.myProfile) == true {
                    // Feed → myProfile → sessionDetail
                    state.feedPath.append(.mySessionDetail(SessionDetailFeature.State(session: session, sessionId: sessionId)))
                } else {
                    // My → mySessionDetail
                    state.myPath.append(.mySessionDetail(SessionDetailFeature.State(session: session, sessionId: sessionId)))
                }
                return .none

            // 설정으로 이동
            case .my(.delegate(.navigateToSetting)):
                // 설정은 항상 My 탭에서만 진입 가능
                state.myPath.append(.setting(SettingFeature.State()))
                return .none
            
            // 온보딩으로 이동 (로그아웃/탈퇴 시)
            case .my(.delegate(.logoutCompleted)),
                 .my(.delegate(.withdrawCompleted)):
                print("로그아웃/탈퇴 완료 → 온보딩 전환")
                state.isLoggedIn = false
                state.selectedTab = .running
                state.onboarding.path.removeAll()
                state.onboarding = OnboardingFeature.State()
                return .none

            // 뒤로 가기
            case .my(.delegate(.navigateBack)):
                // 현재 어느 path를 사용 중인지에 따라 분기
                if state.feedPath.last?.is(\.myProfile) == true {
                    // Feed 탭 경로면 feedPath에서 pop
                    state.feedPath.removeLast()
                } else {
                    // My 탭 경로면 myPath에서 pop
                    state.myPath.removeLast()
                }
                return .none
                
            // MARK: - Path Element Delegates (Running Path)
            // runningPath stack의 각 화면에서 발생하는 액션 처리
            // 주요 화면들: friendList → friendProfile/myProfile
            //           friendProfile (친구 프로필에서 피드 수정/삭제 시 Feed 탭과 동기화)
                
            // 러닝 → 친구 목록 → 뒤로가기
            case .runningPath(.element(id: _, action: .friendList(.backButtonTapped))):
                state.runningPath.removeLast()
                return .none
                
            // 러닝 → 친구 목록 → 본인 프로필
            case .runningPath(.element(id: _, action: .friendList(.delegate(.navigateToMyProfile)))):
                state.runningPath.append(.myProfile)
                return .none
                
            // 러닝 → 친구 목록 → 친구 프로필
            case let .runningPath(.element(id: _, action: .friendList(.delegate(.navigateToFriendProfile(userID))))):
                state.runningPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none
                
            // 러닝 → 친구 목록 → 친구 프로필 → 뒤로가기
            case .runningPath(.element(id: _, action: .friendProfile(.backButtonTapped))):
                state.runningPath.removeLast()
                return .none

            // MARK: - Path Element Delegates (Feed Path)
            // feedPath stack의 각 화면에서 발생하는 액션 처리
            // 주요 화면들: friendList → friendProfile
            //           notificationList → friendProfile/feedDetail/selectSession
            //           certificationUserList → friendProfile/myProfile
            //           feedDetail ↔ editMyFeedDetail
            //           selectSession (피드 업로드)
                
            // 피드 → 친구 목록 → 뒤로 가기
            case .feedPath(.element(id: _, action: .friendList(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none
                
            // 피드 → 친구 목록 → 본인 프로필로 이동 (현재는 친구 목록에 본인 존재 X)
            case .feedPath(.element(id: _, action: .friendList(.delegate(.navigateToMyProfile)))):
                state.feedPath.append(.myProfile)
                return .none

            // 피드 → 친구 목록 → 친구 프로필로 이동
            case let .feedPath(.element(id: _, action: .friendList(.delegate(.navigateToFriendProfile(userID))))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none

            // 피드 → 알림 목록 → 뒤로 가기
            case .feedPath(.element(id: _, action: .notificationList(.backButtonTapped))):
                state.feedPath.removeLast()
                return .send(.feed(.fetchUnreadCount))

            // 피드 → 알림 목록 → 친구 프로필로 이동 (친구 응원 알람을 탭한 경우)
            case let .feedPath(.element(id: _, action: .notificationList(.delegate(.navigateToFriendProfile(userID))))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none

            // 피드 → 알림 목록 → 피드 상세로 이동 (친구 피드 업로드 알람/피드 리액션 알람을 탭한 경우)
            case let .feedPath(.element(id: _, action: .notificationList(.delegate(.navigateToFeedDetail(feedID))))):
                state.feedPath.append(.feedDetail(FeedDetailFeature.State(feedId: feedID, feed: .empty(feedID: feedID))))
                return .none

            // 피드 → 알림 목록 → 세션 선택으로 이동 (피드 업로드 독촉 알람을 탭한 경우)
            case .feedPath(.element(id: _, action: .notificationList(.delegate(.navigateToFeedUpload)))):
                state.feedPath.append(.selectSession(SelectSessionFeature.State()))
                return .none

            // 피드 → 알림 목록 → 러닝으로 전환 (러닝 진행 독촉/신규 가입 러닝 독촉 알람을 탭한 경우)
            case .feedPath(.element(id: _, action: .notificationList(.delegate(.navigateToRunningStart)))):
                state.feedPath.removeLast() // 알림 목록 닫기
                state.selectedTab = .running
                return .none

            // 피드 → 알림 목록 → 친구 목록으로 전환 (신규 가입 친구 추가 독촉 알람을 탭한 경우)
            case .feedPath(.element(id: _, action: .notificationList(.delegate(.navigateToFriendList)))):
                state.feedPath.removeLast() // 알림 목록 닫기
                state.feedPath.append(.friendList(FriendListFeature.State()))
                return .none

            // 피드 → 인증 유저 목록 → 뒤로 가기
            case .feedPath(.element(id: _, action: .certificationUserList(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none
                
            // 피드 → 인증 유저 목록 → 본인 프로필로 이동
            case .feedPath(.element(id: _, action: .certificationUserList(.delegate(.navigateToMyProfile)))):
                state.feedPath.append(.myProfile)
                return .none

            // 피드 → 인증 유저 목록 → 친구 프로필로 이동
            case let .feedPath(.element(id: _, action: .certificationUserList(.delegate(.navigateToFriendProfile(userID))))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none
                
            // 피드 → 피드 상세 → 뒤로가기
            case .feedPath(.element(id: _, action: .feedDetail(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            // 피드 → 피드 상세 → 피드 수정
            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.feedUpdated(feedID, imageURL))))):
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].imageURL = imageURL
                }
                return .send(.feed(.delegate(.feedUpdateCompleted(feedID: feedID, newImageURL: imageURL))))

            // 피드 → 피드 상세 → 피드 삭제
            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.feedDeleted(feedID))))):
                state.feed.feeds.removeAll(where: { $0.feedID == feedID })
                return .send(.feed(.delegate(.feedDeleteCompleted(feedID: feedID))))

            // 피드 → 피드 상세 → 리액션
            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.reactionUpdated(feedID, reactions))))):
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].reactions = reactions
                }
                return .none
                
            // 피드 → 피드 상세 → 본인 프로필
            case .feedPath(.element(id: _, action: .feedDetail(.delegate(.navigateToMyProfile)))):
                // feedPath에 이미 myProfile이 있으면 feedDetail만 dismiss, 없으면 myProfile append
                if state.feedPath.contains(where: { $0.is(\.myProfile) }) {
                    state.feedPath.removeLast()
                } else {
                    state.feedPath.append(.myProfile)
                }
                return .none

            // 피드 → 피드 상세 → 친구 프로필
            case let .feedPath(.element(id: _, action: .feedDetail(.delegate(.navigateToFriendProfile(userID))))):
                state.feedPath.append(.friendProfile(FriendProfileFeature.State(userID: userID)))
                return .none
                
            // 피드 → 피드 수정 → 뒤로가기
            case .feedPath(.element(id: _, action: .editMyFeedDetail(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            // 피드 → 피드 수정 → 수정 완료
            case let .feedPath(.element(id: _, action: .editMyFeedDetail(.delegate(.updateCompleted(feedID, imageURL))))):
                if let index = state.feed.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feed.feeds[index].imageURL = imageURL
                }
                return .send(.feed(.delegate(.feedUpdateCompleted(feedID: feedID, newImageURL: imageURL))))
                
            // 피드 → 세션 선택 → 뒤로가기
            case .feedPath(.element(id: _, action: .selectSession(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            // 피드 → 세션 선택 → 피드 생성 → 피드 업로드 완료
            case .feedPath(.element(_, .selectSession(.delegate(.feedUploadCompleted)))):
                state.shouldShowInterstitialAd = true
                state.adSource = .feedSelectSession
                return .none
                
            case .feedPath(.element(id: _, action: .enterManualSession(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            // 피드 → 세션 상세 → 피드 업로드 완료 → 광고 표시
            case .feedPath(.element(_, .mySessionDetail(.delegate(.feedUploadCompleted)))):
                state.shouldShowInterstitialAd = true
                state.adSource = .sessionDetailFeed
                return .none

            // 피드 → 세션 상세 → 뒤로가기
            case .feedPath(.element(id: _, action: .mySessionDetail(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none
                
            // 피드 → (인증 유저 목록) → 본인 프로필 → 세션 상세 → 피드 상세 → 본인 프로필 : 세션 상세에서 뒤로가기로 처리(중복 push 방지)
            case .feedPath(.element(id: _, action: .mySessionDetail(.delegate(.navigateToMyProfile)))):
                state.feedPath.removeLast()
                return .none
                
            // 피드 → 친구 목록/인증 유저 목록 → 친구 프로필 → 뒤로가기
            case .feedPath(.element(id: _, action: .friendProfile(.backButtonTapped))):
                state.feedPath.removeLast()
                return .none

            // MARK: - Path Element Delegates (My Path)
            // myPath stack의 각 화면에서 발생하는 액션 처리
            // 주요 화면들: myFeedDetail (피드 수정/삭제)
            //           mySessionDetail (세션 상세)
            //           setting (로그아웃/탈퇴)
            //           friendProfile
              
                
            // 마이 → 내 피드 상세 → 뒤로가기
            case .myPath(.element(id: _, action: .myFeedDetail(.backButtonTapped))):
                state.myPath.removeLast()
                return .none
                
            // 마이 → 내 피드 상세 → 피드 수정
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

            // 마이 → 내 피드 상세 → 피드 삭제
            case let .myPath(.element(id: _, action: .myFeedDetail(.delegate(.feedDeleted(feedID))))):
                MyProfileFeature.removeFeedAndCleanupIfEmpty(feedID: feedID, from: &state.my.feeds)
                return .send(.my(.delegate(.feedDeleteCompleted(feedID: feedID))))

            // 마이 → 내 피드 상세 → 본인 프로필 : 피드 상세에서 뒤로가기로 처리(중복 push 방지)
            case .myPath(.element(id: _, action: .myFeedDetail(.delegate(.navigateToMyProfile)))):
                state.myPath.removeLast()
                return .none

            // 마이 → 내 세션 상세 → 뒤로가기
            case .myPath(.element(id: _, action: .mySessionDetail(.backButtonTapped))):
                state.myPath.removeLast()
                return .none

            // 마이 → 내 세션 상세 → 피드 업로드 완료 → 광고 표시
            case .myPath(.element(_, .mySessionDetail(.delegate(.feedUploadCompleted)))):
                state.shouldShowInterstitialAd = true
                state.adSource = .sessionDetailMy
                return .none

            // 마이 → 내 세션 상세 → 피드 상세 → 본인 프로필 : 세션 상세에서 뒤로가기로 처리(중복 push 방지)
            case .myPath(.element(id: _, action: .mySessionDetail(.delegate(.navigateToMyProfile)))):
                // 세션 상세에서 인증 게시물을 보고 내 프로필을 선택한 경우 - 세션 상세 화면 dismiss
                state.myPath.removeLast()
                return .none
                
            // 마이 → 설정 → 뒤로가기
            case .myPath(.element(id: _, action: .setting(.backButtonTapped))):
                state.myPath.removeLast()
                return .none

            // 마이 → 설정 → 로그아웃
            case .myPath(.element(id: _, action: .setting(.delegate(.logoutCompleted)))):
                return .send(.my(.delegate(.logoutCompleted)))

            // 마이 → 설정 → 탈퇴
            case .myPath(.element(id: _, action: .setting(.delegate(.withdrawCompleted)))):
                return .send(.my(.delegate(.withdrawCompleted)))

            default:
                return .none
            }
        }
        .forEach(\.runningPath, action: \.runningPath)
        .forEach(\.feedPath, action: \.feedPath)
        .forEach(\.myPath, action: \.myPath)
    }

    // MARK: - Path Reducers
    // 각 탭별 navigation stack에 push될 수 있는 화면 정의

    /// Running 탭 Navigation Stack
    @Reducer
    enum RunningPath {
        case friendList(FriendListFeature)        // 친구 목록
        case friendProfile(FriendProfileFeature)  // 친구 프로필
        case myProfile                            // 내 프로필 (MyProfileFeature 공유)
    }

    /// Feed 탭 Navigation Stack
    /// - 특징: myProfile을 통해 My 화면 기능 접근 가능 (feedPath 사용)
    @Reducer
    enum FeedPath {
        case friendList(FriendListFeature)                          // 친구 목록
        case notificationList(NotificationListFeature)              // 알림 목록
        case certificationUserList(CertificationUserListFeature)    // 인증 목록 (오늘 같이 뛴 사람들)
        case friendProfile(FriendProfileFeature)                    // 친구 프로필
        case myProfile                                              // 내 프로필 (MyProfileFeature 공유)
        case feedDetail(FeedDetailFeature)                          // 피드 상세
        case editMyFeedDetail(EditFeedDetailFeature)                // 피드 수정
        case selectSession(SelectSessionFeature)                    // 세션 선택 (피드 업로드)
        case enterManualSession(EnterManualSessionFeature)          // 세션 직접 기록 (피드 업로드)
        case mySessionDetail(SessionDetailFeature)                  // 내 세션 상세
    }

    /// My 탭 Navigation Stack
    /// - 주의: Feed 탭에서 myProfile로 진입한 경우 feedPath를 사용하므로 myPath는 사용되지 않음
    @Reducer
    enum MyPath {
        case myFeedDetail(FeedDetailFeature)            // 내 피드 상세
        case mySessionDetail(SessionDetailFeature)      // 내 세션 상세
        case setting(SettingFeature)                    // 설정
    }
}
