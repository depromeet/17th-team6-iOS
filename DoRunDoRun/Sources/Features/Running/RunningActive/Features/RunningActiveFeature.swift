//
//  RunningActiveFeature.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/20/25.

import ComposableArchitecture

@Reducer
struct RunningActiveFeature {
    // MARK: - Dependencies
    @Dependency(\.runningActiveUsecase) var runningActiveUseCase
    
    @ObservableState
    struct State: Equatable {
        /// Entity -> ViewState 매핑 결과
        var statuses: [RunningSnapshotViewState] = []
        var isRunningPaused: Bool = false
        var isShowingStopConfirm: Bool = false
        
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
        
        case pauseButtonTapped
        case resumeButtonTapped
        case stopButtonTapped
        
        case stopConfirmButtonTapped
        case stopCancelButtonTapped
        
        // Stream lifecycle
        case _startStream
        case _snapshotReceived(RunningSnapshot)
        case _streamFinished
        case _streamFailed
    }
    
    // 스트림 작업 식별자
    private enum CancelID { case stream }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
                //MARK: View Cycle
            case .onAppear:
                return .send(._startStream)
                
                // 화면 이탈/중단 시 스트림 취소
            case .onDisappear:
                return .merge(
                    .run { [useCase = self.runningActiveUseCase] _ in
                        await useCase.stop()
                    },
                    .cancel(id: CancelID.stream)
                )
                
                //MARK: UI
            case .pauseButtonTapped:
                state.isRunningPaused = true
                return .run { [useCase = self.runningActiveUseCase] _ in
                    await useCase.pause()
                }
            case .resumeButtonTapped:
                state.isRunningPaused = false
                return .run { [useCase = self.runningActiveUseCase] _ in
                    try await useCase.resume()
                }
            case .stopButtonTapped:
                state.isShowingStopConfirm = true
                return .none
            case .stopCancelButtonTapped:
                state.isShowingStopConfirm = false
                return .none
            case .stopConfirmButtonTapped:
                state.isShowingStopConfirm = false
                
                return .merge(
                    .run { [useCase = self.runningActiveUseCase] _ in
                        await useCase.stop()
                    },
                    .cancel(id: CancelID.stream)
                )
            case .gpsButtonTapped:
                // TODO: 현재 위치 정렬
                return .none

                //MARK: 러닝 스냅샷 스트림
            case ._startStream:
                return .run { [useCase = self.runningActiveUseCase] send in
                    do {
                        let stream = try await useCase.start()
                        for try await snapshot in stream {
                            await send(._snapshotReceived(snapshot))
                        }
                        await send(._streamFinished)
                    } catch {
                        await send(._streamFailed)
                    }
                }
                .cancellable(id: CancelID.stream, cancelInFlight: true)
                
                // 스냅샷 수신 -> ViewState로 매핑하여 축적
            case ._snapshotReceived(let snapshot):
                state.statuses.append(RunningSnapshotViewStateMapper.map(from: snapshot))
                return .none
                // 종료/에러 (필요 시 에러 상태 노출 가능)
            case ._streamFinished:
                return .none
            case ._streamFailed:
                return .none
            }
        }
    }
}
