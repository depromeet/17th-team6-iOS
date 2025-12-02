//
//  FriendProfileFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FriendProfileFeature{
    // MARK: - Dependencies
    @Dependency(\.selfieFeedsUseCase) var selfieFeedsUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        // MARK: Navigation
        @Presents var feedDetail: MyFeedDetailFeature.State?

        // MARK: Feed Data
        var userID: Int
        var feeds: [SelfieFeedViewState] = []
        var userSummary: UserSummaryViewState?
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true

        // MARK: Sub Features State
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        
        // MARK: Failed Requests
        enum FailedRequestType: Equatable {
            case fetchSelfieFeeds(page: Int)
        }
        var lastFailedRequest: FailedRequestType? = nil
    }

    // MARK: - Action
    enum Action: Equatable {
        // Navigation
        case feedItemTapped(SelfieFeedItem)
        case feedDetail(PresentationAction<MyFeedDetailFeature.Action>)

        // Lifecycle
        case onAppear

        // Feed
        case fetchSelfieFeeds(page: Int)
        case fetchSelfieFeedsSuccess(SelfieFeedResult)
        case loadNextPageIfNeeded(currentItem: SelfieFeedViewState?)
        case fetchSelfieFeedsFailure(APIError)

        // Failed Requests
        case setLastFailedRequest(State.FailedRequestType)

        // Sub Feature Action
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        case backButtonTapped
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - Navigation: Feed Detail
            case let .feedItemTapped(feed):
                state.feedDetail = MyFeedDetailFeature.State(feedId: feed.feedID, feed: feed)
                return .none

            case .feedDetail(.presented(.backButtonTapped)):
                state.feedDetail = nil
                return .none

            // MARK: - Lifecycle
            case .onAppear:
                state.feeds = []
                state.currentPage = 0
                state.hasNextPage = true
                
                guard !state.isLoading else { return .none }
                state.isLoading = true
                
                return .send(.fetchSelfieFeeds(page: 0))

            // MARK: - Feed API
            case let .fetchSelfieFeeds(page):
                state.isLoading = true
                return .run { [page, userId = state.userID] send in
                    do {
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
                }

            default:
                return .none
            }
        }
        .ifLet(\.$feedDetail, action: \.feedDetail) {
            MyFeedDetailFeature()
        }
    }
}

// MARK: - API Error Handler
private extension FriendProfileFeature {
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

extension FriendProfileFeature {
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
