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
    @Dependency(\.selfieFeedsUseCase) var selfieFeedsUseCase
    @Dependency(\.runSessionsUseCase) var runSessionsUseCase

    // MARK: - State
    @ObservableState
    struct State {
        // MARK: Navigation
        var path = StackState<Path.State>()

        // MARK: Tabs
        enum Tab: Int, CaseIterable {
            case feed
            case session
        }
        var currentTap: Int = 0
        let totalTaps = Tab.allCases.count

        // MARK: Feed Data
        var feeds: [SelfieFeedViewState] = []
        var userSummary: UserSummaryViewState?
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true
        
        // MARK: Calendar
        var currentMonth: Date = Date()
        var monthTitle: String {
            DateFormatterManager.shared.formatYearMonthLabel(from: currentMonth)
        }

        // MARK: Session Data
        var sessions: [RunningSessionSummaryViewState] = []
        var filteredSessions: [RunningSessionSummaryViewState] {
            sessions.filter {
                CalendarManager.shared.calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month)
            }
        }

        // MARK: Sub Features State
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        
        // MARK: Failed Requests
        enum FailedRequestType: Equatable {
            case fetchSelfieFeeds(page: Int)
            case fetchSessions
        }
        var lastFailedRequest: FailedRequestType? = nil
    }

    // MARK: - Action
    enum Action {
        // Navigation
        case path(StackActionOf<Path>)
        case feedItemTapped(SelfieFeedItem)
        case sessionCardTapped(RunningSessionSummaryViewState)
        case settingButtonTapped

        // Tabs
        case pageChanged(Int)
        case feedTapped
        case sessionTapped

        // Lifecycle
        case onAppear

        // Feed
        case fetchSelfieFeeds(page: Int)
        case fetchSelfieFeedsSuccess(SelfieFeedResult)
        case loadNextPageIfNeeded(currentItem: SelfieFeedViewState?)
        case fetchSelfieFeedsFailure(APIError)

        // Calendar
        case previousMonthTapped
        case nextMonthTapped

        // Sessions
        case fetchSessions
        case fetchSessionsSuccess([RunningSessionSummary])
        case fetchSessionsFailure(APIError)

        // Failed Requests
        case setLastFailedRequest(State.FailedRequestType)

        // Sub Feature Action
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)

        // Delegate
        enum Delegate: Equatable {
            case logoutCompleted
            case withdrawCompleted
            case feedUpdateCompleted(feedID: Int, newImageURL: String?)
            case feedDeleteCompleted(feedID: Int)
        }
        case delegate(Delegate)
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - Tabs
            case let .pageChanged(index):
                state.currentTap = index
                return .none

            case .feedTapped:
                state.currentTap = State.Tab.feed.rawValue
                return .none

            case .sessionTapped:
                state.currentTap = State.Tab.session.rawValue
                return .none

            // MARK: - Navigation: Feed Detail
            case let .feedItemTapped(feed):
                state.path.append(.myFeedDetail(MyFeedDetailFeature.State(feedId: feed.feedID, feed: feed)))
                return .none

            case let .path(.element(id: _, action: .myFeedDetail(.delegate(.feedUpdated(feedID, imageURL))))):
                if let index = state.feeds.firstIndex(where: {
                    if case let .feed(item) = $0.kind {
                        return item.feedID == state.path.last?.myFeedDetail?.feed.feedID
                    }
                    return false
                }) {
                    if case let .feed(item) = state.feeds[index].kind {
                        var updatedFeed = item
                        updatedFeed.imageURL = imageURL
                        state.feeds[index] = .init(id: state.feeds[index].id, kind: .feed(updatedFeed))
                    }
                }
                return .send(.delegate(.feedUpdateCompleted(feedID: feedID, newImageURL: imageURL)))


            case let .path(.element(id: _, action: .myFeedDetail(.delegate(.feedDeleted(feedID))))):
                MyFeature.removeFeedAndCleanupIfEmpty(feedID: feedID, from: &state.feeds)
                return .send(.delegate(.feedDeleteCompleted(feedID: feedID)))

            case .path(.element(id: _, action: .myFeedDetail(.backButtonTapped))):
                state.path.removeLast()
                return .none

            // MARK: - Navigation: Session Detail
            case let .sessionCardTapped(session):
                state.path.append(.mySessionDetail(MySessionDetailFeature.State(session: session, sessionId: session.id)))
                return .none

            case .path(.element(id: _, action: .mySessionDetail(.backButtonTapped))):
                state.path.removeLast()
                return .none

            // MARK: - Navigation: Setting
            case .settingButtonTapped:
                state.path.append(.setting(SettingFeature.State()))
                return .none

            case .path(.element(id: _, action: .setting(.backButtonTapped))):
                state.path.removeLast()
                return .none

            // MARK: - Lifecycle
            case .onAppear:
                state.feeds = []
                state.currentPage = 0
                state.hasNextPage = true
                
                guard !state.isLoading else { return .none }
                state.isLoading = true
                
                return .merge(
                    .send(.fetchSelfieFeeds(page: 0)),
                    .send(.fetchSessions)
                )

            // MARK: - Feed API
            case let .fetchSelfieFeeds(page):
                state.isLoading = true
                return .run { [page] send in
                    do {
                        let userId = UserManager.shared.userId
                        let feeds = try await selfieFeedsUseCase.execute(currentDate: nil, userId: userId, page: page, size: 20)
                        await send(.fetchSelfieFeedsSuccess(feeds))
                    } catch {
                        await send(.setLastFailedRequest(.fetchSelfieFeeds(page: page)))
                        await send(.fetchSelfieFeedsFailure(error as? APIError ?? .unknown))
                    }
                }

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

                if let userSummary = result.userSummary {
                    state.userSummary = UserSummaryViewStateMapper.map(from: userSummary)
                } else {
                    state.userSummary = nil
                }
                return .none

            case let .loadNextPageIfNeeded(currentItem):
                guard let currentItem else { return .none }
                guard !state.isLoading && state.hasNextPage else { return .none }
                let threshold = max(state.feeds.count - 5, 0)
                if let currentIndex = state.feeds.firstIndex(where: { $0.id == currentItem.id }),
                   currentIndex >= threshold {
                    let nextPage = state.currentPage + 1
                    return .send(.fetchSelfieFeeds(page: nextPage))
                }
                return .none

            case let .fetchSelfieFeedsFailure(apiError):
                state.isLoading = false
                return handleAPIError(apiError)

            // MARK: - Calendar
            case .previousMonthTapped:
                if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: state.currentMonth) {
                    state.currentMonth = newDate
                }
                return .send(.fetchSessions)

            case .nextMonthTapped:
                if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: state.currentMonth) {
                    state.currentMonth = newDate
                }
                return .send(.fetchSessions)

            // MARK: - Session API
            case .fetchSessions:
                return .run { [currentMonth = state.currentMonth] send in
                    do {
                        let calendar = Calendar.current
                        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
                        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
                        let sessions = try await runSessionsUseCase.fetchSessions(
                            isSelfied: nil,
                            startDateTime: startOfMonth,
                            endDateTime: endOfMonth
                        )
                        await send(.fetchSessionsSuccess(sessions))
                    } catch {
                        await send(.setLastFailedRequest(.fetchSessions))
                        await send(.fetchSessionsFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .fetchSessionsSuccess(sessions):
                state.sessions = RunningSessionSummaryViewStateMapper.map(
                    from: sessions,
                    currentDate: Date() 
                )
                return .none

            case let .fetchSessionsFailure(apiError):
                state.isLoading = false
                return handleAPIError(apiError)

            // MARK: - Save Request Failure Type
            case let .setLastFailedRequest(request):
                state.lastFailedRequest = request
                return .none

            // MARK: - Retry
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }
                switch failed {
                case let .fetchSelfieFeeds(page):
                    return .send(.fetchSelfieFeeds(page: page))
                case .fetchSessions:
                    return .send(.fetchSessions)
                }

            // MARK: - Delegate
            case .path(.element(id: _, action: .setting(.delegate(.logoutCompleted)))):
                return .send(.delegate(.logoutCompleted))

            case .path(.element(id: _, action: .setting(.delegate(.withdrawCompleted)))):
                return .send(.delegate(.withdrawCompleted))

            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Path Reducer
    @Reducer
    enum Path {
        case myFeedDetail(MyFeedDetailFeature)
        case mySessionDetail(MySessionDetailFeature)
        case setting(SettingFeature)
    }
}

// MARK: - API Error Handler
private extension MyFeature {
    func handleAPIError(_ apiError: APIError) -> Effect<Action> {
        switch apiError {
        case .networkError:
            return .send(.networkErrorPopup(.show))
        case .notFound:
            return .send(.serverError(.show(.notFound)))
        case .internalServer:
            return .send(.serverError(.show(.internalServer)))
        case .badGateway:
            return .send(.serverError(.show(.badGateway)))
        default:
            print("[API ERROR]", apiError.userMessage)
            return .none
        }
    }
}

extension MyFeature {
    /// 피드 삭제 후, 해당 피드가 없으면 monthHeader까지 깔끔하게 청소
    static func removeFeedAndCleanupIfEmpty(
        feedID: Int,
        from feeds: inout [SelfieFeedViewState]
    ) {
        feeds.removeAll { viewState in
            guard case let .feed(item) = viewState.kind else { return false }
            return item.feedID == feedID
        }

        // 남은 피드가 하나도 없으면 → monthHeader도 함께 제거
        let hasAnyFeed = feeds.contains { viewState in
            if case .feed = viewState.kind { return true }
            return false
        }

        if !hasAnyFeed {
            feeds = []
        }
    }
}
