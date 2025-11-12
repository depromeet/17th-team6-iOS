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

    @ObservableState
    struct State: Equatable {
        var detail: RunningDetailViewState

        /// 뷰 모드
        enum ViewMode: Equatable {
            case viewing              // 과거 기록 보기 (읽기 전용)
            case completing(sessionId: Int)  // 방금 끝난 러닝 (이미지 캡처 + 서버 업로드)
        }
        var viewMode: ViewMode

        var isCompletingSession: Bool = false

        // 이미지 캡처 상태
        var isCapturingImage: Bool = false
        var captureRetryCount: Int = 0

        // 에러 처리
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()

        /// API 요청 실패 시, 어떤 요청이 실패했는지 저장하여 재시도 시 사용
        enum FailedRequestType: Equatable {
            case uploadToServer
        }
        var lastFailedRequest: FailedRequestType? = nil
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case backButtonTapped
        case recordVerificationButtonTapped

        // 이미지 캡처
        case startImageCapture
        case imageCaptureTimeout
        case imageCaptureMaxRetriesReached
        case getRouteImageData

        case sendRunningData
        case sessionCompletedSuccessfully(mapImageURL: String?)
        case sessionCompletedWithError(APIError)

        // 에러 처리
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        case toast(ToastFeature.Action)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case backButtonTapped
        }
    }

    private enum CancelID {
        case imageCaptureTimeout
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        BindingReducer()
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.backButtonTapped))

            case .recordVerificationButtonTapped:
                // TODO: 화면 전환 로직 추가
                return .none

            // MARK: - 이미지 캡처
            case .startImageCapture:
                // completing 모드가 아니거나 이미 캡처 중이면 무시
                guard case .completing = state.viewMode,
                      !state.isCapturingImage else {
                    return .none
                }

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
                guard state.detail.mapImageData == nil else {
                    return .none
                }

                state.captureRetryCount += 1

                // 최대 3회 재시도
                if state.captureRetryCount < 3 {
                    print("⚠️ Image capture timeout, retry \(state.captureRetryCount)/3")
                    // 재시도: 다시 3초 타임아웃 설정
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
                // 이미지 들어온 거 확인
                state.isCapturingImage = false
                state.captureRetryCount = 0
                return .merge(
                    .cancel(id: CancelID.imageCaptureTimeout),
                    .send(.sendRunningData)
                )

            case .sendRunningData:
                // completing 모드에서만 서버 업로드 실행
                guard case .completing(let sessionId) = state.viewMode,
                      let mapImageData = state.detail.mapImageData,
                      !state.isCompletingSession else {
                    print("⚠️ Session completion skipped: viewMode=\(state.viewMode), hasMapImage=\(state.detail.mapImageData != nil), isCompleting=\(state.isCompletingSession)")
                    return .none
                }

                state.isCompletingSession = true

                return .run { [completer = self.sessionCompleter, detail = state.detail] send in
                    do {
                        // ViewState → Domain 변환
                        let domainDetail = RunningDetailViewStateMapper.toDomain(from: detail)
                        let mapImageURL = try await completer.complete(
                            sessionId: sessionId,
                            detail: domainDetail,
                            mapImage: mapImageData
                        )
                        await send(.sessionCompletedSuccessfully(mapImageURL: mapImageURL))
                    } catch let error as APIError {
                        await send(.sessionCompletedWithError(error))
                    } catch {
                        await send(.sessionCompletedWithError(.internalServer))
                    }
                }

            case .sessionCompletedSuccessfully(let mapImageURL):
                state.isCompletingSession = false
                if let urlString = mapImageURL, let url = URL(string: urlString) {
                    state.detail.mapImageURL = url
                }
                print("✅ Session completed successfully, mapImageURL: \(mapImageURL ?? "nil")")
                return .none

            case .sessionCompletedWithError(let error):
                state.isCompletingSession = false
                state.lastFailedRequest = .uploadToServer
                return handleAPIError(error)

            case .binding(_):
                return .none

            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }

                switch failed {
                case .uploadToServer:
                    return .send(.sendRunningData)
                }

            case .networkErrorPopup:
                return .none

            case .serverError:
                return .none

            case .toast:
                return .none

            case .delegate:
                return .none
            }
        }
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
