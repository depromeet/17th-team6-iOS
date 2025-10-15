import ComposableArchitecture

@Reducer
struct RunningFeature {
    @ObservableState
    struct State: Equatable {}
    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
