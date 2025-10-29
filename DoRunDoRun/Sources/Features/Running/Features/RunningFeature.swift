import UIKit

import ComposableArchitecture

enum RunningPhase {
    case ready
    case countdown
    case active
}

@Reducer
struct RunningFeature {
    @ObservableState
    struct State: Equatable {
        var phase: RunningPhase = .ready

        var ready = RunningReadyFeature.State()
        var countdown = RunningCountdownFeature.State()
        var active = RunningActiveFeature.State()
    }

    enum Action: Equatable {
        case ready(RunningReadyFeature.Action)
        case countdown(RunningCountdownFeature.Action)
        case active(RunningActiveFeature.Action)

        case updatePhase(RunningPhase)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.ready, action: \.ready) { RunningReadyFeature() }
        Scope(state: \.countdown, action: \.countdown) { RunningCountdownFeature() }
        Scope(state: \.active, action: \.active) { RunningActiveFeature() }

        Reduce { state, action in
            switch action {

            // Ready → Countdown
            case .ready(.startButtonTapped):
                UIApplication.shared.setTabBarHidden(true)
                state.phase = .countdown
                return .none

            // Countdown 완료 → Active
            case .countdown(.countdownCompleted):
                state.phase = .active
                return .none

            // Active 종료 
            case .active(.stopConfirmButtonTapped):
                // TODO: 런닝 종료 기록 화면 이동
                UIApplication.shared.setTabBarHidden(false)
                state.phase = .ready
                return .none

            // 외부에서 강제 phase 변경
            case let .updatePhase(phase):
                state.phase = phase
                return .none

            default:
                return .none
            }
        }
    }
}
