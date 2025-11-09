import ComposableArchitecture

@Reducer
struct FeedFeature {
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        var weekDayInfos: [FeedDayInfo] = []
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
        case destination(PresentationAction<Destination.Action>)
    }

    @Reducer
    enum Destination {
        case feedDetail(FeedDetailFeature)
        case uploadFeed(UploadFeedFeature)
    }

    @Dependency(\.getFeedRepository) var feedRepository: FeedRepositoryProtocol

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                case .fetchFeed:
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
