import UIKit

import ComposableArchitecture

enum RunningPhase: Equatable {
    case ready
    case countdown
    case active
}

@Reducer
struct RunningFeature {
    @Dependency(\.runningUseCase) var runningUseCase
    @Dependency(\.userLocationUseCase) var userLocationUseCase

    @ObservableState
    struct State {
        var sessionId: Int? = nil
        
        var phase: RunningPhase = .ready
        var ready = RunningReadyFeature.State()
        var countdown = RunningCountdownFeature.State()
        var active = RunningActiveFeature.State()
        
        @Presents var runningDetail: RunningDetailFeature.State?
    }

    enum Action {
        case updatePhase(RunningPhase)
        case ready(RunningReadyFeature.Action)
        case countdown(RunningCountdownFeature.Action)
        case active(RunningActiveFeature.Action)

        // 세션 생성 관련
        case _createSession
        case _sessionCreated(Int)
        case _sessionCreationFailed(APIError)

        // 스트림 관련
        case _startTracking
        case _snapshotReceived(RunningSnapshot)
        case _streamFinished
        case _streamFailed

        // 러닝 제어
        case pauseRunning
        case resumeRunning
        case stopRunning
        
        case runningDetail(PresentationAction<RunningDetailFeature.Action>)
        enum Delegate: Equatable {
            case navigateToFriendList
            case navigateToFriendProfile(userID: Int)
            case navigateBack
            case navigateToFeed
            case feedUploadCompleted
        }
        case delegate(Delegate)
    }
    
    private enum CancelID { case runningStream }

    var body: some ReducerOf<Self> {
        Scope(state: \.ready, action: \.ready) { RunningReadyFeature() }
        Scope(state: \.countdown, action: \.countdown) { RunningCountdownFeature() }
        Scope(state: \.active, action: \.active) { RunningActiveFeature() }

        Reduce { state, action in
            switch action {
            // Ready → 세션 생성 시작
            case .ready(.startButtonTapped):
                return .run { [userLocationUseCase] send in
                    let hasPermission = await userLocationUseCase.hasLocationPermission()
                    if !hasPermission {
                        await send(.ready(.locationPermissionDenied))
                    } else {
                        await send(._createSession)
                    }
                }

            case ._createSession:
                return .run { [useCase = self.runningUseCase] send in
                    do {
                        let sessionId = try await useCase.createSession()
                        await send(._sessionCreated(sessionId))
                    } catch let error as APIError {
                        await send(._sessionCreationFailed(error))
                    } catch {
                        await send(._sessionCreationFailed(.internalServer))
                    }
                }

            case ._sessionCreated(let id):
                state.phase = .countdown
                state.sessionId = id
                UIApplication.shared.setTabBarHidden(true)
                return .none

            case ._sessionCreationFailed(let error):
                state.ready.lastFailedRequest = .createSession
                return handleAPIError(error)

            // Countdown 완료 → Active: 스트림 시작
            case .countdown(.countdownCompleted):
                state.phase = .active
                return .send(._startTracking)

            case ._startTracking:
                guard state.sessionId != nil else {
                    return .send(._sessionCreationFailed(.internalServer))
                }

                return .run { [useCase = self.runningUseCase] send in
                    do {
                        let stream = try await useCase.startTracking()
                        for try await snapshot in stream {
                            await send(._snapshotReceived(snapshot))
                        }
                        await send(._streamFinished)
                    } catch {
                        await send(._streamFailed)
                    }
                }
                .cancellable(id: CancelID.runningStream, cancelInFlight: true)

            case ._snapshotReceived(let snapshot):
                // ViewState로 변환하여 Active Feature에 전달
                let viewState = RunningSnapshotViewStateMapper.map(from: snapshot)
                return .send(.active(.updateSnapshot(viewState)))

            case ._streamFinished:
                print("✅ Running stream finished")
                return .none

            case ._streamFailed:
                print("⚠️ Running stream failed")
                return .none

            // Active Feature delegate 처리
            case .active(.delegate(.pauseRequested)):
                return .send(.pauseRunning)

            case .pauseRunning:
                return .run { [useCase = self.runningUseCase] _ in
                    await useCase.pause()
                }

            case .active(.delegate(.resumeRequested)):
                return .send(.resumeRunning)

            case .resumeRunning:
                return .run { [useCase = self.runningUseCase] _ in
                    try await useCase.resume()
                }

            case .active(.delegate(.stopConfirmed)):
                return .send(.stopRunning)

            case .stopRunning:
                return .run { [useCase = self.runningUseCase] send in
                    let detail = await useCase.stop()
                    await send(.active(.delegate(.didFinish(final: detail))))
                }
                .cancellable(id: CancelID.runningStream)

            // Active → Parent delegate: 최종 상세 결과 전달
            case let .active(.delegate(.didFinish(final))):
                let detail = RunningDetailViewStateMapper.map(from: final)
                state.runningDetail = RunningDetailFeature.State(detail: detail)

                // 초기 상태로 복귀
                state.phase = .ready
                state.sessionId = nil
                UIApplication.shared.setTabBarHidden(false)
                state.active = RunningActiveFeature.State()

                return .none

            // 외부에서 강제 phase 변경
            case let .updatePhase(phase):
                state.phase = phase
                return .none
                
            // RunningReady delegate relay
            case .ready(.delegate(.navigateToFriendList)):
                return .send(.delegate(.navigateToFriendList))
                
            case .ready(.delegate(.navigateToFriendProfile(let userID))):
                return .send(.delegate(.navigateToFriendProfile(userID: userID)))
                
            case .ready(.delegate(.navigateBack)):
                return .send(.delegate(.navigateBack))

            // RunningDetail delegate relay
            case .runningDetail(.presented(.delegate(.backButtonTapped))):
                state.runningDetail = nil
                return .send(.delegate(.navigateToFeed))
                
            case .runningDetail(.presented(.delegate(.feedUploadCompleted))):
                state.runningDetail = nil
                return .send(.delegate(.feedUploadCompleted))

            default:
                return .none
            }
        }
        .ifLet(\.$runningDetail, action: \.runningDetail) {
            RunningDetailFeature()
        }
    }

    // MARK: - 에러 처리
    private func handleAPIError(_ apiError: APIError) -> Effect<Action> {
        switch apiError {
        case .networkError:
            return .send(.ready(.networkErrorPopup(.show)))
        case .notFound:
            return .send(.ready(.serverError(.show(.notFound))))
        case .internalServer:
            return .send(.ready(.serverError(.show(.internalServer))))
        case .badGateway:
            return .send(.ready(.serverError(.show(.badGateway))))
        default:
            return .send(.ready(.toast(.show(apiError.userMessage))))
        }
    }
}
