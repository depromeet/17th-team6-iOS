//
//  TimerFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

import ComposableArchitecture

@Reducer
struct TimerFeature {
    @ObservableState
    struct State: Equatable {
        var isActive = false
        var remainingSeconds = 0
        var timerText: String {
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    enum Action: Equatable {
        case start(seconds: Int)
        case restart(seconds: Int)
        case tick
        case ended
    }

    enum CancelID { case timer }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .start(seconds):
                state.remainingSeconds = seconds
                state.isActive = true

                return .run { send in
                    for _ in (0..<seconds).reversed() {
                        try await Task.sleep(for: .seconds(1))
                        await send(.tick)
                    }
                    await send(.ended)
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)

            case let .restart(seconds):
                state.remainingSeconds = seconds
                state.isActive = true
                return .send(.start(seconds: seconds))

            case .tick:
                guard state.remainingSeconds > 0 else { return .none }
                state.remainingSeconds -= 1
                if state.remainingSeconds == 0 {
                    state.isActive = false
                    return .send(.ended)
                }
                return .none

            case .ended:
                state.isActive = false
                return .none
            }
        }
    }
}
