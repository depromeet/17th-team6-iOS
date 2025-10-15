import Foundation
import ComposableArchitecture

struct Friend: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let time: String?
    let distance: String?
    let location: String?
    let isMine: Bool
    let isRunning: Bool
    let isSent: Bool
    let isFocus: Bool
}

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
