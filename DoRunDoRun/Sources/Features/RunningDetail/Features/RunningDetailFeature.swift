//
//  RunningDetailFeature.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/29/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct RunningDetailFeature {
    @Dependency(\.runningSessionCompleter) var sessionCompleter
    @Dependency(\.selfieUploadableUseCase) var selfieUploadableUseCase

    @ObservableState
    struct State: Equatable {
        var detail: RunningDetailViewState
        var selfieUploadable: SelfieUploadableViewState?
        var isUploadable: Bool {
            selfieUploadable?.isUploadable == true
        }
        
        var captureRetryCount: Int = 0
        var isCapturingImage = false
        
        var isCompletingSession = false
        
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
    
        enum FailedRequestType: Equatable {
            case uploadToServer
        }
        var lastFailedRequest: FailedRequestType? = nil
        
        @Presents var createFeed: CreateFeedFeature.State?
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case backButtonTapped
        case recordVerificationButtonTapped

        case startImageCapture
        case imageCaptureTimeout
        case imageCaptureMaxRetriesReached
        case getRouteImageData

        case sendRunningData
        case sessionCompletedSuccessfully(mapImageURL: String?)
        case sessionCompletedWithError(APIError)
        
        case checkUploadable
        case checkUploadableSuccess(SelfieUploadableResult)
        case checkUploadableFailure(APIError)

        case toast(ToastFeature.Action)
        case serverError(ServerErrorFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)

        enum Delegate: Equatable {
            case backButtonTapped
            case feedUploadCompleted
        }
        case delegate(Delegate)
        
        case createFeed(PresentationAction<CreateFeedFeature.Action>)
    }

    private enum CancelID {
        case imageCaptureTimeout
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }

        BindingReducer()
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.backButtonTapped))
                
            case .checkUploadable:
                guard let sessionId = state.detail.sessionId else { return .none }
                
                return .run { send in
                    do {
                        let result = try await selfieUploadableUseCase.execute(runSessionId: sessionId)
                        await send(.checkUploadableSuccess(result))
                    } catch {
                        await send(.checkUploadableFailure(error as? APIError ?? .unknown))
                    }
                }
                
            case let .checkUploadableSuccess(result):
                let mapped = SelfieUploadableViewStateMapper.map(from: result)
                state.selfieUploadable = mapped
                return .none

                
            case let .checkUploadableFailure(error):
                return handleAPIError(error)
                
            case .recordVerificationButtonTapped:
                guard let uploadable = state.selfieUploadable else {
                    return .none
                }

                if uploadable.isUploadable {
                    let summary = RunningDetailViewStateMapper.map(from: state.detail)
                    state.createFeed = CreateFeedFeature.State(session: summary)
                }
                return .none
                
            case .createFeed(.presented(.delegate(.uploadCompleted))):
                // 업로드 완료 시 CreateFeed 화면 닫고 피드로 이동
                state.createFeed = nil
                return .send(.delegate(.feedUploadCompleted))
                
            case .createFeed(.presented(.backButtonTapped)):
                state.createFeed = nil
                return .none

            case .startImageCapture:
                // 이미 캡처 중이면 무시
                guard !state.isCapturingImage else { return .none }
                
                state.isCapturingImage = true
                state.captureRetryCount = 0

                // 3초 타임아웃 설정
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.imageCaptureTimeout)
                }
                .cancellable(id: CancelID.imageCaptureTimeout)

            case .imageCaptureTimeout:
                // 이미 이미지가 들어왔으면 무시
                guard state.detail.mapImageData == nil else { return .none }
                
                state.captureRetryCount += 1

                // 최대 3회 캡쳐 재시도
                if state.captureRetryCount < 3 {
                    print("⚠️ Image capture timeout, retry \(state.captureRetryCount)/3")
                    return .run { send in
                        try await Task.sleep(for: .seconds(3))
                        await send(.imageCaptureTimeout)
                    }
                    .cancellable(id: CancelID.imageCaptureTimeout)
                } else {
                    // 3회 실패
                    return .send(.imageCaptureMaxRetriesReached)
                }

            case .imageCaptureMaxRetriesReached:
                state.isCapturingImage = false
                state.captureRetryCount = 0
                return .send(.toast(.show("이미지 캡처에 실패했습니다")))

            case .getRouteImageData:
                state.isCapturingImage = false
                state.captureRetryCount = 0
                return .merge(
                    .cancel(id: CancelID.imageCaptureTimeout),
                    .send(.sendRunningData)
                )

            // 세션 업로드
            case .sendRunningData:
                print("세선 업로드 시작")
                guard let sessionId = state.detail.sessionId,
                      let mapImageData = state.detail.mapImageData,
                      !state.isCompletingSession else {
                    print("⚠️ Session completion skipped: hasMapImage=\(state.detail.mapImageData != nil), isCompleting=\(state.isCompletingSession)")
                    return .none
                }

                state.isCompletingSession = true

                return .run { [completer = self.sessionCompleter, detail = state.detail] send in
                    do {
                        // ViewState → RunningCompleteRequest 변환
                        let completeRequest = RunningDetailViewStateMapper.toCompleteRequest(from: detail)

                        let mapImageURL = try await completer.complete(
                            sessionId: sessionId,
                            request: completeRequest,
                            mapImage: mapImageData
                        )
                        await send(.sessionCompletedSuccessfully(mapImageURL: mapImageURL))
                    } catch let error as APIError {
                        await send(.sessionCompletedWithError(error))
                    } catch {
                        await send(.sessionCompletedWithError(.unknown))
                    }
                }

            // 세션 업로드 성공
            case .sessionCompletedSuccessfully(let mapImageURL):
                state.isCompletingSession = false
                if let urlString = mapImageURL, let url = URL(string: urlString) {
                    state.detail.mapImageURL = url
                }
                print("✅ Session completed successfully, mapImageURL: \(mapImageURL ?? "nil")")
                return .none

            // 세션 업로드 실패
            case .sessionCompletedWithError(let error):
                print("서버에 세션 업로드 실패!!!! \(error)")
                state.isCompletingSession = false
                state.lastFailedRequest = .uploadToServer
                return handleAPIError(error)

            // 재시도
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }
                switch failed {
                case .uploadToServer:
                    return .send(.sendRunningData)
                }
                
            default:
                return .none
            }
        }
        .ifLet(\.$createFeed, action: \.createFeed) { CreateFeedFeature() }
    }

    // MARK: - 에러 처리
    private func handleAPIError(_ apiError: APIError) -> Effect<Action> {
        switch apiError {
        case .networkError:
            return .send(.networkErrorPopup(.show))
        case .notFound:
            return .send(.serverError(.show(.notFound)))
        case .internalServer:
            return .send(.serverError(.show(.internalServer)))
        case .badGateway:
            return .send(.serverError(.show(.badGateway)))
        default:
            // 기타 에러는 콘솔 로그만 출력
            print("⚠️ Failed to complete session: \(apiError.userMessage)")
            return .none
        }
    }
}
