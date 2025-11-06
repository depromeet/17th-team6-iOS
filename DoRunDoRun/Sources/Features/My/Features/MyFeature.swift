import Foundation
import ComposableArchitecture

@Reducer
struct MyFeature {
    @Dependency(\.selfieFeedsUseCase) var selfieFeedsUseCase
    @Dependency(\.runSessionsUseCase) var runSessionsUseCase

    @ObservableState
    struct State {
        var path = StackState<Path.State>()

        enum Tab: Int, CaseIterable {
            case certification
            case record
        }
        var currentTap: Int = 0
        let totalTaps = Tab.allCases.count
        
        var currentMonth: Date = Date()
        var monthTitle: String {
            DateFormatterManager.shared.monthTitle(from: currentMonth)
        }
        var feeds: [SelfieFeedViewState] = []
        var userSummary: UserSummaryViewState?
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true
        
        var sessions: [RunningSessionSummaryViewState] = []
        var filteredSessions: [RunningSessionSummaryViewState] {
            sessions.filter {
                CalendarManager.shared.calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month)
            }
        }
    }
    enum Action {
        case path(StackActionOf<Path>)
        case sessionTapped(RunningSessionSummaryViewState)

        case pageChanged(Int)
        case certificationTapped
        case recordTapped
        
        case onAppear
        
        case fetchSelfieFeeds(page: Int)
        case fetchSelfieFeedsSuccess(SelfieFeedResult)

        case loadNextPageIfNeeded(currentItem: SelfieFeedViewState?)
        
        case fetchSessions
        case fetchSessionsSuccess([RunningSessionSummary])
        
        case previousMonthTapped
        case nextMonthTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .sessionTapped(session):
                state.path.append(.runningDetail(RunningDetailFeature.State(detail: RunningDetailViewStateMapper.map(from: session))))
                return .none
                
            case .path(.element(id: _, action: .runningDetail(.backButtonTapped))):
                state.path.removeLast()
                return .none
                
            case let .pageChanged(index):
                state.currentTap = index
                return .none

            case .certificationTapped:
                state.currentTap = State.Tab.certification.rawValue
                return .none

            case .recordTapped:
                state.currentTap = State.Tab.record.rawValue
                return .none
                
            case .onAppear:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .merge(
                    .send(.fetchSelfieFeeds(page: 0)),
                    .send(.fetchSessions)
                )
                
            case let .fetchSelfieFeeds(page):
                state.isLoading = true
                return .run { [page] send in
                    do {
                        let feeds = try await selfieFeedsUseCase.execute(currentDate: nil, userId: 1, page: page, size: 20)
                        await send(.fetchSelfieFeedsSuccess(feeds))
                    } catch {
                        if let apiError = error as? APIError {
                            switch apiError {
                            default:
                                print(apiError.userMessage)
                            }
                        } else {
                            print(APIError.unknown.userMessage)
                        }
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
                
                let userSummary = result.userSummary
                state.userSummary = UserSummaryViewStateMapper.map(from: userSummary)
                
                return .none
                
            case let .loadNextPageIfNeeded(currentItem):
                guard let currentItem else { return .none }
                guard !state.isLoading && state.hasNextPage else { return .none }

                // 데이터 개수에 따라 thresholdIndex를 안전하게 계산
                let threshold = max(state.feeds.count - 5, 0)
                if let currentIndex = state.feeds.firstIndex(where: { $0.id == currentItem.id }),
                   currentIndex >= threshold {
                    let nextPage = state.currentPage + 1
                    print("[DEBUG] 다음 페이지 요청: \(nextPage)")
                    return .send(.fetchSelfieFeeds(page: nextPage))
                }
                return .none

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
                            switch apiError {
                            default:
                                print(apiError.userMessage)
                            }
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }

            case let .fetchSessionsSuccess(sessions):
                let mapped = sessions.map { RunningSessionSummaryViewStateMapper.map(from: $0) }
                state.sessions = mapped
                return .none
                
            case .previousMonthTapped:
                if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: state.currentMonth) {
                    state.currentMonth = newDate
                }
                return .none

            case .nextMonthTapped:
                if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: state.currentMonth) {
                    state.currentMonth = newDate
                }
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    @Reducer
    enum Path {
        case runningDetail(RunningDetailFeature)
    }
}
