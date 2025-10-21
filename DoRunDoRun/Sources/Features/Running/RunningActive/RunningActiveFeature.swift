import ComposableArchitecture

@Reducer
struct RunningActiveFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {
        case stopButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .stopButtonTapped:
                // 실제 러닝 종료 로직은 상위 Feature(RunningFeature)에서 담당
                return .none
            }
        }
    }
}
