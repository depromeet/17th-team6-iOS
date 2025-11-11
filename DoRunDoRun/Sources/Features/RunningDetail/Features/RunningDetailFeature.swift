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
        var sessionId: Int?
        var isCompletingSession: Bool = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case backButtonTapped
        case recordVerificationButtonTapped
        case getRouteImageData

        case sendRunningData
        case sessionCompletedSuccessfully
        case sessionCompletedWithError(String)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case backButtonTapped
        }
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.backButtonTapped))

            case .recordVerificationButtonTapped:
                // TODO: 화면 전환 로직 추가
                return .none

            case .getRouteImageData:
                // 이미지 들어온 거 확인
                return .send(.sendRunningData)

            case .sendRunningData:
                // 이미지 데이터 들어오면 최종 데이터 서버로 전달
                guard let sessionId = state.sessionId,
                      let mapImageData = state.detail.mapImageData,
                      !state.isCompletingSession else {
                    print("⚠️ Session completion skipped: sessionId=\(state.sessionId?.description ?? "nil"), hasMapImage=\(state.detail.mapImageData != nil), isCompleting=\(state.isCompletingSession)")
                    return .none
                }

                state.isCompletingSession = true

                return .run { [completer = self.sessionCompleter, detail = state.detail] send in
                    do {
                        // ViewState → Domain 변환
                        let domainDetail = RunningDetailViewStateMapper.toDomain(from: detail)
                        try await completer.complete(
                            sessionId: sessionId,
                            detail: domainDetail,
                            mapImage: mapImageData
                        )
                        await send(.sessionCompletedSuccessfully)
                    } catch {
                        await send(.sessionCompletedWithError(error.localizedDescription))
                    }
                }

            case .sessionCompletedSuccessfully:
                state.isCompletingSession = false
                print("✅ Session completed successfully")
                return .none

            case .sessionCompletedWithError(let message):
                state.isCompletingSession = false
                print("⚠️ Failed to complete session: \(message)")
                // TODO: 에러 토스트 표시
                return .none

            case .binding(_):
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
