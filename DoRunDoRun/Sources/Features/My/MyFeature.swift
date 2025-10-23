import ComposableArchitecture

@Reducer
struct MyFeature {
    @ObservableState
    struct State: Equatable {}
    enum Action: Equatable {
        case dummy
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dummy:
                return .none
            }
        }
    }
}
