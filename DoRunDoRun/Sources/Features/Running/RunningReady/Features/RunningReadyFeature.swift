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
        @Presents var friendList: FriendListFeature.State?
        var toast = ToastFeature.State()

        /// Entity -> ViewState 매핑 결과
        var statuses: [FriendRunningStatusViewState] = []
        
        /// 현재 포커싱된 친구의 ID (지도 이동 / 하이라이트용)
        var focusedFriendID: Int? = nil
        
        // 페이지네이션
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true
    }

    // MARK: - Action
    enum Action: Equatable {
        case friendList(PresentationAction<FriendListFeature.Action>)
        case toast(ToastFeature.Action)
        case onAppear
        case loadStatuses(page: Int)
        case statusSuccess([FriendRunningStatus])
        case loadNextPageIfNeeded(currentItem: FriendRunningStatusViewState?)
        case statusFailure(String)
        case friendTapped(Int)
        case cheerButtonTapped(Int, String)
        case reactionSuccess(Int, String)
        case reactionFailure(Int, String)
        case gpsButtonTapped
        case friendListButtonTapped
        case startButtonTapped
    }

    // MARK: - Reducer Body
    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }

        Reduce { state, action in
            switch action {

            // MARK: 화면 진입 시 - 친구 현황 불러오기
            case .onAppear:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .send(.loadStatuses(page: 0))

            // MARK: 러닝 상태 조회 (시작 페이지)
            case let .loadStatuses(page):
                state.isLoading = true
                return .run { [page] send in
                    do {
                        let results = try await statusUseCase.execute(page: page, size: 20)
                        await send(.statusSuccess(results))
                    } catch {
                        await send(.statusFailure(error.localizedDescription))
                    }
                }
            
            // MARK: 러닝 상태 조회 성공
            case let .statusSuccess(results):
                state.isLoading = false
                if results.isEmpty {
                    state.hasNextPage = false
                } else {
                    let mapped = results.map { FriendRunningStatusViewStateMapper.map(from: $0) }
                    if state.currentPage == 0 {
                        // 내 프로필 이미지 URL 저장 (서버가 내려줄 경우)
                        if let me = results.first(where: { $0.isMe }),
                           let imageURL = me.profileImageURL {
                            UserManager.shared.profileImageURL = imageURL
                        }
                        // 첫 페이지
                        state.statuses = mapped
                        // 포커싱은 첫 로드 시 한 번만
                        if let me = results.first(where: { $0.isMe }) {
                            state.focusedFriendID = me.id
                        }
                    } else {
                        // 다음 페이지 append
                        state.statuses.append(contentsOf: mapped)
                    }
                    state.currentPage += 1
                }
                return .none
                
            // MARK: 러닝 상태 조회 (페이지네이션)
            case let .loadNextPageIfNeeded(currentItem):
                guard let currentItem else { return .none }
                guard !state.isLoading && state.hasNextPage else { return .none }

                // 데이터 개수에 따라 thresholdIndex를 안전하게 계산
                let threshold = max(state.statuses.count - 5, 0)
                if let currentIndex = state.statuses.firstIndex(where: { $0.id == currentItem.id }),
                   currentIndex >= threshold {
                    let nextPage = state.currentPage + 1
                    print("[DEBUG] 다음 페이지 요청: \(nextPage)")
                    return .send(.loadStatuses(page: nextPage))
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
            case let .cheerButtonTapped(id, name):
                return .run { send in
                    do {
                        try await reactionUseCase.sendReaction(to: id)
                        await send(.reactionSuccess(id, name))
                    } catch {
                        await send(.reactionFailure(id, error.localizedDescription))
                    }
                }

            // MARK: 응원 성공 → 상태 반영
            case let .reactionSuccess(id, name):
                if let index = state.statuses.firstIndex(where: { $0.id == id }) {
                    state.statuses[index].isCheerable = false
                }
                return .send(.toast(.show("잠자는 ’\(name)’님을 깨웠어요!")))

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
                state.friendList = FriendListFeature.State()
                return .none

            // 친구 목록 닫을 때
            case .friendList(.presented(.backButtonTapped)):
                state.friendList = nil
                return .none
                
            // MARK: 오늘의 러닝 시작 버튼
            case .startButtonTapped:
                state.statuses = []
                // 실제 러닝 시작 로직은 상위 Feature(RunningFeature)에서 담당
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$friendList, action: \.friendList) {
            FriendListFeature()
        }
    }
}
