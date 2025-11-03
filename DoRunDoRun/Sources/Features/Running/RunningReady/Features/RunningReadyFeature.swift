//
//  RunningReadyFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import ComposableArchitecture

@Reducer
struct RunningReadyFeature {
    // MARK: - Dependencies
    @Dependency(\.friendRunningStatusUseCase) var statusUseCase
    @Dependency(\.friendReactionUseCase) var reactionUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        /// Entity -> ViewState 매핑 결과
        var statuses: [FriendRunningStatusViewState] = []
        
        /// 현재 포커싱된 친구의 ID (지도 이동 / 하이라이트용)
        var focusedFriendID: Int? = nil
        
        /// 이미 응원한 친구 ID 목록 (중복 응원 방지)
        var sentReactions: Set<Int> = []
    }

    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case statusSuccess([FriendRunningStatus])
        case statusFailure(String)
        case friendTapped(Int)
        case cheerButtonTapped(Int)
        case reactionSuccess(Int)
        case reactionFailure(Int, String)
        case gpsButtonTapped
        case friendListButtonTapped
        case startButtonTapped
    }

    // MARK: - Reducer Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            // MARK: 화면 진입 시 - 친구 현황 불러오기
            case .onAppear:
                return .run { send in
                    do {
                        let statuses = try await statusUseCase.fetchStatuses()
                        await send(.statusSuccess(statuses))
                    } catch {
                        await send(.statusFailure(error.localizedDescription))
                    }
                }

            // MARK: 러닝 상태 조회 성공
            case let .statusSuccess(statuses):
                // DTO(Entity) → ViewState 변환
                state.statuses = statuses.map { FriendRunningStatusViewStateMapper.map(from: $0) }

                // 본인(나)인 친구를 찾아 포커싱
                if let me = statuses.first(where: { $0.isMe }) {
                    state.focusedFriendID = me.id
                }

                return .none

            // MARK: 러닝 상태 조회 실패
            case let .statusFailure(message):
                print("Fetch Error:", message)
                return .none

            // MARK: 친구 셀 탭 (포커스 전환)
            case let .friendTapped(id):
                state.focusedFriendID = id
                return .none

            // MARK: 응원 버튼 탭
            case let .cheerButtonTapped(id):
                return .run { send in
                    do {
                        try await reactionUseCase.sendReaction(to: id)
                        await send(.reactionSuccess(id))
                    } catch {
                        await send(.reactionFailure(id, error.localizedDescription))
                    }
                }

            // MARK: 응원 성공 → 상태 반영
            case let .reactionSuccess(id):
                state.sentReactions.insert(id)
                return .none

            // MARK: 응원 실패 (로깅)
            case let .reactionFailure(id, message):
                print("응원 실패 [\(id)]: \(message)")
                return .none

            // MARK: GPS 버튼
            case .gpsButtonTapped:
                // TODO: 내 위치로 카메라 이동 구현
                return .none
                
            // MARK: 친구 목록 버튼
            case .friendListButtonTapped:
                // TODO: 친구 목록 화면 이동 로직 연결 예정
                return .none
                
            // MARK: 오늘의 러닝 시작 버튼
            case .startButtonTapped:
                state.statuses = []
                // 실제 러닝 시작 로직은 상위 Feature(RunningFeature)에서 담당
                return .none
            }
        }
    }
}
