//
//  EnterManualSessionFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/10/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EnterManualSessionFeature {

    // MARK: - Dependencies
    @Dependency(\.manualSessionCreator) var manualSessionCreator
    @Dependency(\.analyticsTracker) var analytics

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var startTime: Date? = nil
        var duration: DateComponents? = nil
        var distanceWhole: Int? = nil
        var distanceDecimal: Int? = nil
        var paceMinute: Int? = nil
        var paceSecond: Int? = nil
        var cadence: String = ""
        var isRequiredFieldsFilled: Bool {
            startTime != nil &&
            duration != nil &&
            distanceWhole != nil &&
            distanceDecimal != nil
        }
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        @Presents var createFeed: CreateFeedFeature.State?

    }

    // MARK: - Action
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case addButtonTapped
        case backButtonTapped
        case createManualSessionSuccess(RunningSessionSummary)
        case createManualSessionFailure(APIError)

        // 에러 관련
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)

        // Navigation
        case createFeed(PresentationAction<CreateFeedFeature.Action>)

        enum DelegateAction: Equatable {
            case feedUploadCompleted
        }
        case delegate(DelegateAction)
    }

    // MARK: - Reducer

    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {
                
            // MARK: - 추가하기 버튼 탭
            case .addButtonTapped:
                guard let startTime = state.startTime,
                      let duration = state.duration,
                      let distanceWhole = state.distanceWhole,
                      let distanceDecimal = state.distanceDecimal else {
                    return .none
                }

                state.isLoading = true

                // ISO8601 변환
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let startedAt = formatter.string(from: startTime)

                // 단위 변환
                let durationTotal = RunningConverterManager.hmsToSeconds(duration)
                let distanceTotal = RunningConverterManager.kmToMeters(
                    whole: distanceWhole,
                    decimal: distanceDecimal
                )
                let paceAvg = RunningConverterManager.paceToSeconds(
                    minute: state.paceMinute ?? 0,
                    second: state.paceSecond ?? 0
                )
                let cadenceAvg = Int(state.cadence) ?? 0

                let request = ManualSessionRequestDTO(
                    startedAt: startedAt,
                    durationTotal: durationTotal,
                    distanceTotal: distanceTotal,
                    paceAvg: paceAvg,
                    cadenceAvg: cadenceAvg
                )

                return .run { send in
                    do {
                        let data = try await manualSessionCreator.execute(request: request)
                        await send(.createManualSessionSuccess(data))
                    } catch {
                        await send(.createManualSessionFailure(error as? APIError ?? .unknown))
                    }
                }

            // MARK: - 생성 성공
            case let .createManualSessionSuccess(entity):
                state.isLoading = false

                let mapper = RunningSessionSummaryViewStateMapper()
                guard let session = mapper.map(from: [entity]).first else { return .none }

                state.createFeed = .init(
                    entryPoint: .inputManual,
                    session: session
                )

                return .none

            // MARK: - 생성 실패
            case let .createManualSessionFailure(error):
                state.isLoading = false
                return handleAPIError(error)

            case .backButtonTapped:
                return .none

            case .binding:
                return .none

            // MARK: - CreateFeed 델리게이트
            case .createFeed(.presented(.delegate(.uploadCompleted))):
                state.createFeed = nil
                return .send(.delegate(.feedUploadCompleted))

            case .createFeed(.presented(.backButtonTapped)):
                state.createFeed = nil
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$createFeed, action: \.createFeed) { CreateFeedFeature() }
    }
}

private extension EnterManualSessionFeature {
    func handleAPIError(_ apiError: APIError) -> Effect<Action> {
        switch apiError {
        case .networkError: return .send(.networkErrorPopup(.show))
        case .notFound: return .send(.serverError(.show(.notFound)))
        case .internalServer: return .send(.serverError(.show(.internalServer)))
        case .badGateway: return .send(.serverError(.show(.badGateway)))
        default: return .none
        }
    }
}
