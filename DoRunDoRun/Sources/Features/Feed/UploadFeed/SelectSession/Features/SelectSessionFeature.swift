//
//  SelectSessionFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SelectSessionFeature {
    // MARK: - Dependencies
    @Dependency(\.runSessionsUseCase) var runSessionsUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        /// 업로드 가능한 러닝 세션 목록 (ViewState)
        var sessions: [RunningSessionSummaryViewState] = []
        /// 로딩 상태
        var isLoading: Bool = false
        /// 서버/네트워크 에러 상태
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        /// 오늘 중 하나라도 이미 인증 완료된 세션이 있는지 여부
        var isAnyCompleted: Bool = false
        /// 현재 선택된 세션 ID
        var selectedSessionID: Int? = nil

        @Presents var createFeed: CreateFeedFeature.State?
    }

    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case fetchSessions
        case fetchSessionsSuccess([RunningSessionSummaryViewState], Bool)
        case fetchSessionsFailure(APIError)
        case sessionTapped(RunningSessionSummaryViewState)
        case loadButtonTapped
        case backButtonTapped

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
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - 화면 진입
            case .onAppear:
                return .send(.fetchSessions)

            // MARK: - 세션 목록 조회
            case .fetchSessions:
                state.isLoading = true

                // 오늘 날짜 00:00 ~ 현재 시각
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: Date())
                let now = Date()

                return .run { send in
                    do {
                        let entities = try await runSessionsUseCase.fetchSessions(
                            isSelfied: nil, // 모든 세션 포함
                            startDateTime: startOfDay,
                            endDateTime: now
                        )

                        // ViewState 변환
                        let mapped = entities.map(RunningSessionSummaryViewStateMapper.map)

                        // 업로드 가능한 세션 (아직 인증 안 한 세션)
                        let available = mapped.filter { $0.tagStatus == .possible }

                        // 오늘 중 하나라도 이미 인증 완료된 세션이 있는지
                        let anyCompleted = mapped.contains { $0.tagStatus == .completed }

                        await send(.fetchSessionsSuccess(available, anyCompleted))
                    } catch {
                        await send(.fetchSessionsFailure(error as? APIError ?? .unknown))
                    }
                }


            // MARK: - 조회 성공
            case let .fetchSessionsSuccess(available, anyCompleted):
                state.isLoading = false
                state.sessions = available
                state.isAnyCompleted = anyCompleted
                return .none

            // MARK: - 조회 실패
            case let .fetchSessionsFailure(error):
                state.isLoading = false
                return handleAPIError(error)


            // MARK: - 세션 탭
            case let .sessionTapped(session):
                if state.selectedSessionID == session.id {
                    state.selectedSessionID = nil // 다시 탭하면 선택 해제
                } else {
                    state.selectedSessionID = session.id
                }
                return .none

            case .loadButtonTapped:
                guard let selectedID = state.selectedSessionID,
                      let selected = state.sessions.first(where: { $0.id == selectedID }) else {
                    return .none
                }
                state.createFeed = .init(session: selected)
                return .none
                
            case .createFeed(.presented(.delegate(.uploadCompleted))):
                // 업로드 완료 시 CreateFeed 화면 닫고 피드로 이동
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

private extension SelectSessionFeature {
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
