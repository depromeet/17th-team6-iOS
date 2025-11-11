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
        @Presents var runningDetail: RunningDetailFeature.State?
        
        var phase: RunningPhase = .ready
        
        var ready = RunningReadyFeature.State()
        var countdown = RunningCountdownFeature.State()
        var active = RunningActiveFeature.State()
    }
    
    enum Action: Equatable {
        case runningDetail(PresentationAction<RunningDetailFeature.Action>)

        case ready(RunningReadyFeature.Action)
        case countdown(RunningCountdownFeature.Action)
        case active(RunningActiveFeature.Action)

        case updatePhase(RunningPhase)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case navigateToFeed
        }
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

            // Active → Parent delegate: 최종 상세 결과 전달
            case let .active(.delegate(.didFinish(final, sessionId))):
                state.runningDetail = RunningDetailFeature.State(
                    detail: RunningDetailViewStateMapper.map(from: final),
                    sessionId: sessionId
                )
                
                // 초기 상태로 복귀
                UIApplication.shared.setTabBarHidden(false)
                state.phase = .ready
                state.active = RunningActiveFeature.State()
                
                return .none
                
            // 외부에서 강제 phase 변경
            case let .updatePhase(phase):
                state.phase = phase
                return .none

            // RunningDetail delegate: 뒤로가기 버튼
            case .runningDetail(.presented(.delegate(.backButtonTapped))):
                state.runningDetail = nil
                return .send(.delegate(.navigateToFeed))

            case .runningDetail:
                return .none

            case .delegate:
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$runningDetail, action: \.runningDetail) {
            RunningDetailFeature()
        }
    }
}
