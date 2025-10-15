import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        enum Tab: Hashable { case running, feed, my }

        var selectedTab: Tab = .running
        var running = RunningReadyFeature.State()
        var feed = FeedFeature.State()
        var my = MyFeature.State()
    }

    enum Action: Equatable {
        case tabSelected(State.Tab)
        case running(RunningReadyFeature.Action)
        case feed(FeedFeature.Action)
        case my(MyFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.running, action: \.running) { RunningReadyFeature() }
        Scope(state: \.feed, action: \.feed) { FeedFeature() }
        Scope(state: \.my, action: \.my) { MyFeature() }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .running, .feed, .my:
                return .none
            }
        }
    }
}
