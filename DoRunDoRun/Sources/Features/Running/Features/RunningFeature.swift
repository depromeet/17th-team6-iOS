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

    @ObservableState
    struct State {
        @Presents var runningDetail: RunningDetailFeature.State?

        var phase: RunningPhase = .ready

        // 세션 ID 관리
        var sessionId: Int? = nil

        var ready = RunningReadyFeature.State()
        var countdown = RunningCountdownFeature.State()
        var active = RunningActiveFeature.State()

        // Path 기반 네비게이션
        var path = StackState<Path.State>()
    }

    @Reducer
    enum Path {
        case detail(RunningDetailFeature)
        case createFeed(CreateFeedFeature)
    }

    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case runningDetail(PresentationAction<RunningDetailFeature.Action>)

        case ready(RunningReadyFeature.Action)
        case countdown(RunningCountdownFeature.Action)
        case active(RunningActiveFeature.Action)

        case updatePhase(RunningPhase)

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

        case delegate(Delegate)

        enum Delegate: Equatable {
            case navigateToFeed
        }
    }
    
    private enum CancelID {
        case runningStream
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.ready, action: \.ready) { RunningReadyFeature() }
        Scope(state: \.countdown, action: \.countdown) { RunningCountdownFeature() }
        Scope(state: \.active, action: \.active) { RunningActiveFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - Path Navigation
            case .path(.element(id: _, action: .detail(.delegate(.navigateToCreateFeed(let summary))))):
                // Detail에서 CreateFeed로 이동
                state.path.append(.createFeed(CreateFeedFeature.State(session: summary)))
                return .none

            case .path(.element(id: _, action: .detail(.delegate(.backButtonTapped)))):
                // Detail에서 뒤로가기
                state.path.removeAll()
                state.runningDetail = nil
                return .send(.delegate(.navigateToFeed))

            case .path(.element(id: _, action: .createFeed(.delegate(.uploadCompleted)))):
                // CreateFeed 업로드 완료 → Feed 탭으로 이동
                state.path.removeAll()
                state.runningDetail = nil
                return .send(.delegate(.navigateToFeed))

            case .path(.element(id: _, action: .createFeed(.backButtonTapped))):
                // CreateFeed에서 뒤로가기 → Detail로 돌아가기
                if state.path.count > 1 {
                    state.path.removeLast()
                }
                return .none

            case .path:
                return .none

            // Ready → 세션 생성 시작
            case .ready(.startButtonTapped):
                return .send(._createSession)

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
                // 세션 생성 성공 → Countdown으로 전환
                state.sessionId = id
                
                UIApplication.shared.setTabBarHidden(true)
                state.phase = .countdown
                return .none

            case ._sessionCreationFailed(let error):
                // lastFailedRequest 설정 (재시도용)
                state.ready.lastFailedRequest = .createSession

                // handleAPIError 메서드 사용
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
                // TODO: 에러 처리
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
                let viewMode: RunningDetailFeature.State.ViewMode = final.sessionId != nil ? .completing : .viewing

                let detailState = RunningDetailFeature.State(
                    detail: RunningDetailViewStateMapper.map(from: final),
                    viewMode: viewMode
                )

                // path에 Detail 추가
                state.path.append(.detail(detailState))

                // 초기 상태로 복귀
                UIApplication.shared.setTabBarHidden(false)
                state.phase = .ready
                state.sessionId = nil
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
        .forEach(\.path, action: \.path)
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
