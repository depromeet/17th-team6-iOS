//
//  MyFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyFeature {
    // MARK: - Dependencies
    /// 셀피 피드 목록을 가져오는 유즈케이스
    @Dependency(\.selfieFeedsUseCase) var selfieFeedsUseCase
    /// 러닝 세션 데이터를 가져오는 유즈케이스
    @Dependency(\.runSessionsUseCase) var runSessionsUseCase

    // MARK: - State
    @ObservableState
    struct State {
        // MARK: Navigation
        /// NavigationStack 내의 경로 상태
        var path = StackState<Path.State>()

        // MARK: Tabs
        /// 나의 탭 화면의 하위 탭 타입
        enum Tab: Int, CaseIterable {
            /// 피드 탭
            case feed
            /// 세션  탭
            case session
        }

        /// 현재 선택된 탭 인덱스
        var currentTap: Int = 0
        /// 전체 탭 개수
        let totalTaps = Tab.allCases.count

        // MARK: Calendar
        /// 현재 표시 중인 월의 기준 날짜
        var currentMonth: Date = Date()
        /// 화면에 표시되는 월 타이틀 (ex. "2025년 11월")
        var monthTitle: String {
            DateFormatterManager.shared.formatYearMonthLabel(from: currentMonth)
        }

        // MARK: Feed Data
        /// 셀피 피드 목록 (월별 헤더 + 피드 셀 구조)
        var feeds: [SelfieFeedViewState] = []
        /// 상단 요약 영역에 표시되는 유저 정보
        var userSummary: UserSummaryViewState?
        /// 현재 로드된 페이지 (0부터 시작)
        var currentPage = 0
        /// 네트워크 요청 중 여부
        var isLoading = false
        /// 다음 페이지가 존재하는지 여부
        var hasNextPage = true

        // MARK: Session Data
        /// 최근 1년간의 러닝 세션 요약 목록
        var sessions: [RunningSessionSummaryViewState] = []
        /// 현재 월에 해당하는 세션만 필터링한 목록
        var filteredSessions: [RunningSessionSummaryViewState] {
            sessions.filter {
                CalendarManager.shared.calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month)
            }
        }
    }

    // MARK: - Action
    enum Action {
        // MARK: Navigation
        /// 하위 네비게이션 스택 관련 액션
        case path(StackActionOf<Path>)
        /// 피드 셀 탭 시 (상세 화면 이동)
        case feedItemTapped(SelfieFeedItem)
        /// 세션 셀 탭 시 (러닝 상세 화면 이동)
        case sessionCardTapped(RunningSessionSummaryViewState)
        /// 설정 버튼 탭 시(설정 화면 이동)
        case settingButtonTapped

        // MARK: Tabs
        /// 페이지 인덱스 변경 시 (TabView 전환 시점)
        case pageChanged(Int)
        /// 피드 탭 버튼 탭
        case feedTapped
        /// 세션 탭 버튼 탭
        case sessionTapped

        // MARK: Lifecycle
        /// 뷰 등장 시 최초 호출
        case onAppear

        // MARK: Feed
        /// 셀피 피드 데이터 요청
        case fetchSelfieFeeds(page: Int)
        /// 셀피 피드 요청 성공
        case fetchSelfieFeedsSuccess(SelfieFeedResult)
        /// 스크롤 하단 도달 시 다음 페이지 로드
        case loadNextPageIfNeeded(currentItem: SelfieFeedViewState?)

        // MARK: Sessions
        /// 러닝 세션 데이터 요청
        case fetchSessions
        /// 러닝 세션 요청 성공
        case fetchSessionsSuccess([RunningSessionSummary])

        // MARK: Calendar
        /// 이전 달 버튼 탭
        case previousMonthTapped
        /// 다음 달 버튼 탭
        case nextMonthTapped
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            // MARK: - 피드 상세 화면 이동
            case let .feedItemTapped(feed):
                state.path.append(.myFeedDetail(MyFeedDetailFeature.State(feed: feed)))
                return .none

            // 피드 상세 → 뒤로가기 시
            case .path(.element(id: _, action: .myFeedDetail(.backButtonTapped))):
                state.path.removeLast()
                return .none

            // MARK: - 러닝 상세 화면 이동
            case let .sessionCardTapped(session):
                state.path.append(.runningDetail(RunningDetailFeature.State(detail: RunningDetailViewStateMapper.map(from: session))))
                return .none

            // 러닝 상세 → 뒤로가기 시
            case .path(.element(id: _, action: .runningDetail(.backButtonTapped))):
                state.path.removeLast()
                return .none
                
            // MARK: - 설정 버튼 탭
            case .settingButtonTapped:
                state.path.append(.setting(SettingFeature.State()))
                return .none
                
                // 설정 → 뒤로가기 시
            case .path(.element(id: _, action: .setting(.backButtonTapped))):
                state.path.removeLast()
                return .none

            // MARK: - 탭 전환
            case let .pageChanged(index):
                state.currentTap = index
                return .none

            case .feedTapped:
                state.currentTap = State.Tab.feed.rawValue
                return .none

            case .sessionTapped:
                state.currentTap = State.Tab.session.rawValue
                return .none

            // MARK: - onAppear: 초기 데이터 요청
            case .onAppear:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .merge(
                    .send(.fetchSelfieFeeds(page: 0)),
                    .send(.fetchSessions)
                )

            // MARK: - 셀피 피드 요청
            case let .fetchSelfieFeeds(page):
                state.isLoading = true
                return .run { [page] send in
                    do {
                        // TODO: 실제 유저의 아이디로 교체 필요
                        let feeds = try await selfieFeedsUseCase.execute(currentDate: nil, userId: 1, page: page, size: 20)
                        await send(.fetchSelfieFeedsSuccess(feeds))
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.userMessage)
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }

            // MARK: - 셀피 피드 요청 성공
            case let .fetchSelfieFeedsSuccess(result):
                state.isLoading = false
                
                let feeds = result.feeds
                if feeds.isEmpty {
                    state.hasNextPage = false
                } else {
                    let mapped = SelfieFeedViewStateMapper.map(from: feeds)
                    if state.currentPage == 0 {
                        state.feeds = mapped
                    } else {
                        let newItems = mapped.filter { newItem in
                            !state.feeds.contains(where: { $0.id == newItem.id })
                        }
                        state.feeds.append(contentsOf: newItems)
                    }
                    state.currentPage += 1
                }
                
                let userSummary = result.userSummary
                state.userSummary = UserSummaryViewStateMapper.map(from: userSummary)
                
                return .none

            // MARK: - 무한 스크롤
            case let .loadNextPageIfNeeded(currentItem):
                guard let currentItem else { return .none }
                guard !state.isLoading && state.hasNextPage else { return .none }

                // 리스트 끝 근처에서 다음 페이지 요청
                let threshold = max(state.feeds.count - 5, 0)
                if let currentIndex = state.feeds.firstIndex(where: { $0.id == currentItem.id }),
                   currentIndex >= threshold {
                    let nextPage = state.currentPage + 1
                    print("[DEBUG] 다음 페이지 요청: \(nextPage)")
                    return .send(.fetchSelfieFeeds(page: nextPage))
                }
                return .none

            // MARK: - 세션 데이터 요청
            case .fetchSessions:
                return .run { send in
                    do {
                        let oneYearAgoDate = CalendarManager.shared.dateOneYearAgo()
                        let sessions = try await runSessionsUseCase.fetchSessions(
                            isSelfied: false,
                            startDateTime: oneYearAgoDate
                        )
                        await send(.fetchSessionsSuccess(sessions))
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.userMessage)
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }

            // MARK: - 세션 요청 성공
            case let .fetchSessionsSuccess(sessions):
                let mapped = sessions.map { RunningSessionSummaryViewStateMapper.map(from: $0) }
                state.sessions = mapped
                return .none

            // MARK: - 이전 달 버튼 탭
            case .previousMonthTapped:
                if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: state.currentMonth) {
                    state.currentMonth = newDate
                }
                return .none

            // MARK: - 다음 달 버튼 탭
            case .nextMonthTapped:
                if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: state.currentMonth) {
                    state.currentMonth = newDate
                }
                return .none

            default:
                return .none
            }
        }
        // Path 관련 액션 처리 (하위 리듀서 연결)
        .forEach(\.path, action: \.path)
    }

    // MARK: - Path Reducer (Navigation Destinations)
    @Reducer
    enum Path {
        /// 피드 상세 화면
        case myFeedDetail(MyFeedDetailFeature)
        /// 러닝 상세 화면
        case runningDetail(RunningDetailFeature)
        /// 설정 화면
        case setting(SettingFeature)

    }
}
