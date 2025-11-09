import ComposableArchitecture
import Foundation

@Reducer
struct FeedFeature {
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        var weekDayInfos: [FeedDayInfo] = []
        var currentWeekOfMonth: Int = 2
        var feedList: FeedList? = nil

        var viewModel = ViewModel()
        struct ViewModel {
            var userSummary: UserSummary?
            var feedList: [FeedViewModel] = []
        }
    }

    var feedList: FeedList? = nil

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchFeed
        case feedResponse(FeedList)
        case tapFeedItem(FeedViewModel)
        case tapUploadButton
        case tapCertificateFriends
        case previousWeek
        case nextWeek
        case destination(PresentationAction<Destination.Action>)
    }

    @Reducer
    enum Destination {
        case feedDetail(FeedDetailFeature)
        case uploadFeed(UploadFeedFeature)
        case certificateFriendsList(CertificateFriendsListFeature)
    }

    @Dependency(\.getFeedRepository) var feedRepository: FeedRepositoryProtocol

    func generateWeekDayInfos(for weekOfMonth: Int) -> [FeedDayInfo] {
        let calendar = Calendar.current
        let today = Date()
        let todayDay = calendar.component(.day, from: today)

        // 현재 월의 첫째 날
        let components = calendar.dateComponents([.year, .month], from: today)
        guard let firstDayOfMonth = calendar.date(from: components) else {
            return []
        }

        // 첫째 날의 요일 (1: 일요일, 2: 월요일, ...)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        // 첫 번째 일요일까지의 오프셋 (일요일이 1이므로)
        let offsetToFirstSunday = (8 - firstWeekday) % 7

        // 해당 주차의 일요일 날짜
        let sundayDay = offsetToFirstSunday + (weekOfMonth - 1) * 7 + 1

        var weekDayInfos: [FeedDayInfo] = []
        let weekDays: [WeekDay] = [.sun, .mon, .tue, .wed, .thu, .fri, .sat]

        for (index, weekDay) in weekDays.enumerated() {
            let day = sundayDay + index
            weekDayInfos.append(
                FeedDayInfo(
                    weekDay: weekDay,
                    day: day,
                    isItToday: day == todayDay,
                    count: 0
                )
            )
        }

        return weekDayInfos
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                case .fetchFeed:
                    if state.weekDayInfos.isEmpty {
                        state.weekDayInfos = generateWeekDayInfos(for: state.currentWeekOfMonth)
                    }
                    return .run { send in
                        do {
                            let worker = FeedWorker(repository: feedRepository)
                            let feedList = try await worker.feedList(currentDate: "2025-10-31", userId: 0, page: 0, size: 20)
                            await send(.feedResponse(feedList))
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                case let .feedResponse(feedList):
                    state.feedList = feedList
                    state.viewModel.userSummary = feedList.userSummary
                    state.viewModel.feedList = feedList.feeds.map { feed in
                        FeedListMapper.toViewModel(from: feed)
                    }
                    return .none
                case let .tapFeedItem(feedViewModel):
                    state.destination = .feedDetail(
                        FeedDetailFeature.State(feedViewModel: feedViewModel)
                    )
                    return .none
                case .tapUploadButton:
                    state.destination = .uploadFeed(
                        UploadFeedFeature.State()
                    )
                    return .none
                case .tapCertificateFriends:
                    state.destination = .certificateFriendsList(
                        CertificateFriendsListFeature.State()
                    )
                    return .none
                case .previousWeek:
                    if state.currentWeekOfMonth > 1 {
                        state.currentWeekOfMonth -= 1
                        state.weekDayInfos = generateWeekDayInfos(for: state.currentWeekOfMonth)
                    }
                    return .none
                case .nextWeek:
                    if state.currentWeekOfMonth < 5 {
                        state.currentWeekOfMonth += 1
                        state.weekDayInfos = generateWeekDayInfos(for: state.currentWeekOfMonth)
                    }
                    return .none
                default:
                    return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}



extension DependencyValues {
    var getFeedRepository: FeedRepositoryProtocol {
        get { self[FeedRepositoryKey.self] }
        set { self[FeedRepositoryKey.self] = newValue }
    }
}

private enum FeedRepositoryKey: DependencyKey {
    static let liveValue: FeedRepositoryProtocol = FeedRepository()
    static let testValue: FeedRepositoryProtocol = FeedRepository(type: .stubbing)
    static let previewValue: FeedRepositoryProtocol = FeedRepository(type: .stubbing)
}


struct FeedDayInfo {
    let weekDay: WeekDay
    let day: Int
    let isItToday: Bool
    let count: Int
}

enum WeekDay: Int {
    case sun = 1
    case mon = 2
    case tue = 3
    case wed = 4
    case thu = 5
    case fri = 6
    case sat = 7

    var title: String {
        switch self {
            case .sun: return "일"
            case .mon: return "월"
            case .tue: return "화"
            case .wed: return "수"
            case .thu: return "목"
            case .fri: return "금"
            case .sat: return "토"
        }
    }
}
