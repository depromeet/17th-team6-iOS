//
//  RunningActiveFeature.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/20/25.

import ComposableArchitecture

@Reducer
struct RunningActiveFeature {
    // Parent notification
    enum Delegate: Equatable {
        case pauseRequested
        case resumeRequested
        case stopConfirmed
        case didFinish(final: RunningDetail, sessionId: Int?)
    }
    
    @ObservableState
    struct State: Equatable {
        /// Entity -> ViewState 매핑 결과
        var statuses: [RunningSnapshotViewState] = []
        var isRunningPaused: Bool = false
        var isShowingStopConfirm: Bool = false

        /// GPS 버튼 - 내 위치 자동 추적 여부 (Active 단계)
        var isFollowingLocation: Bool = true

        var routeCoordinates: [RunningCoordinateViewState] {
            statuses.compactMap { $0.lastCoordinate }
        }

        /// 마지막 스냅샷
       private var lastSnapshot: RunningSnapshotViewState? {
            statuses.last
        }

        /// UI 표시용
        var distanceText: String { lastSnapshot?.distanceText ?? "0.00km" }
        var paceText: String { lastSnapshot?.paceText ?? "-'--''" }
        var durationText: String { lastSnapshot?.durationText ?? "0:00:00" }
        var cadenceText: String { lastSnapshot?.cadenceText ?? "- spm" }
    }
    
    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case onDisappear

        case gpsButtonTapped
        case mapGestureDetected // 사용자가 지도를 움직임 (Following OFF)

        case pauseButtonTapped
        case resumeButtonTapped
        case stopButtonTapped

        case stopConfirmButtonTapped
        case stopCancelButtonTapped

        // 부모로부터 스냅샷 수신
        case updateSnapshot(RunningSnapshotViewState)

        case delegate(Delegate)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

                //MARK: View Cycle
            case .onAppear:
                // 아무것도 하지 않음 - 부모가 자동으로 스트림 시작
                return .none

            case .onDisappear:
                // 부모가 스트림 관리
                return .none

                //MARK: UI
            case .pauseButtonTapped:
                state.isRunningPaused = true
                return .send(.delegate(.pauseRequested))

            case .resumeButtonTapped:
                state.isRunningPaused = false
                return .send(.delegate(.resumeRequested))

            case .stopButtonTapped:
                state.isShowingStopConfirm = true
                return .none

            case .stopCancelButtonTapped:
                state.isShowingStopConfirm = false
                return .none

            case .stopConfirmButtonTapped:
                state.isShowingStopConfirm = false
                return .send(.delegate(.stopConfirmed))

            case .gpsButtonTapped:
                // Following ON/OFF 토글
                state.isFollowingLocation.toggle()
                return .none

            case .mapGestureDetected:
                // 사용자가 지도를 움직이면 Following 해제
                state.isFollowingLocation = false
                return .none

                //MARK: 부모로부터 스냅샷 수신
            case .updateSnapshot(let viewState):
                state.statuses.append(viewState)
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
