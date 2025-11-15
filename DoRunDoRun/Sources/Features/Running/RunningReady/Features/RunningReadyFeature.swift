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
    @Dependency(\.userLocationUseCase) var userLocationUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        @Presents var friendList: FriendListFeature.State?
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        
        var shouldRefresh: Bool = true

        /// Entity -> ViewState 매핑 결과
        var statuses: [FriendRunningStatusViewState] = []

        /// 현재 포커싱된 친구의 ID (지도 이동 / 하이라이트용)
        var focusedFriendID: Int? = nil

        /// GPS Following 모드 (사용자 위치 추적 여부)
        var isFollowingUserLocation: Bool = true

        /// 사용자의 현재 위치
        var userLocation: UserLocationViewState? = nil

        // 페이지네이션
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true

        /// API 요청 실패 시, 어떤 요청이 실패했는지 저장하여 재시도 시 사용
        enum FailedRequestType: Equatable {
            case loadStatuses
            case createSession
        }
        var lastFailedRequest: FailedRequestType? = nil
    }

    // MARK: - Action
    enum Action: Equatable {
        case friendList(PresentationAction<FriendListFeature.Action>)
        case toast(ToastFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        case onAppear
        case onDisappear
        case loadStatuses(page: Int)
        case statusSuccess([FriendRunningStatus])
        case loadNextPageIfNeeded(currentItem: FriendRunningStatusViewState?)
        case statusFailure(APIError)
        
        case friendTapped(Int)
        
        case cheerButtonTapped(Int, String)
        case reactionSuccess(Int, String)
        case reactionFailure(Int, String)
        
        case gpsButtonTapped
        case userLocationUpdated(RunningCoordinate)
        case mapGestureDetected

        case friendListButtonTapped

        case startButtonTapped
    }

    // MARK: - Reducer Body
    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: 화면 진입 시 - 친구 현황 불러오기 + 위치 추적 시작
            case .onAppear:
                // 상태 초기화
                state.statuses = []
                state.currentPage = 0
                state.hasNextPage = true
                state.focusedFriendID = nil
                state.isFollowingUserLocation = true

                guard !state.isLoading else { return .none }
                state.isLoading = true

                return .merge(
                    .send(.loadStatuses(page: 0)),
                    .run { [userLocationUseCase] send in
                        do {
                            let locationStream = try await userLocationUseCase.startTracking()
                            for try await coordinate in locationStream {
                                await send(.userLocationUpdated(coordinate))
                            }
                        } catch {
                            print("[GPS] 위치 추적 실패: \(error)")
                        }
                    }
                )

            // MARK: 화면 종료 시 - 위치 추적 중단 및 상태 초기화
            case .onDisappear:
                state.userLocation = nil
                state.isFollowingUserLocation = true  // 다음 진입 시를 위해 초기값으로 리셋
                return .run { [userLocationUseCase] _ in
                    await userLocationUseCase.stopTracking()
                    print("[GPS] 위치 추적 중단")
                }

            // MARK: 러닝 상태 조회 (시작 페이지)
            case let .loadStatuses(page):
                state.isLoading = true
                return .run { [page] send in
                    do {
                        let results = try await statusUseCase.execute(page: page, size: 20)
                        await send(.statusSuccess(results))
                    } catch {
                        if let apiError = error as? APIError {
                            await send(.statusFailure(apiError))
                        } else {
                            await send(.statusFailure(.unknown))
                        }
                    }
                }
            
            // MARK: 러닝 상태 조회 성공
            case let .statusSuccess(results):
                state.isLoading = false

                if results.isEmpty {
                    state.hasNextPage = false
                    return .none
                }

                let mapped = results.map { FriendRunningStatusViewStateMapper.map(from: $0) }

                // MARK: 1) 첫 페이지 처리
                if state.currentPage == 0 {

                    // 🔥 내 프로필 이미지 저장 로직 유지
                    if let me = results.first(where: { $0.isMe }),
                       let imageURL = me.profileImageURL {
                        UserManager.shared.profileImageURL = imageURL
                    }

                    // 첫 페이지는 무조건 새로 세팅
                    state.statuses = mapped

                } else {

                    // MARK: 2) 중복 append 방지 (userId 기준)
                    let newItems = mapped.filter { new in
                        !state.statuses.contains(where: { $0.id == new.id })
                    }

                    // 중복되지 않는 애들만 append
                    state.statuses.append(contentsOf: newItems)
                }

                // MARK: 3) 페이지 증가
                state.currentPage += 1
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
            case let .statusFailure(apiError):
                state.isLoading = false
                state.lastFailedRequest = .loadStatuses
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
                    return .send(.toast(.show(apiError.userMessage)))
                }

            // MARK: 재시도
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }

                switch failed {
                case .loadStatuses:
                    return .send(.onAppear)
                case .createSession:
                    return .send(.startButtonTapped)
                }

            // MARK: 친구 셀 탭 (포커스 전환) - GPS Following 해제
            case let .friendTapped(id):
                state.isFollowingUserLocation = false
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

            // MARK: GPS 버튼 - Following 모드 토글
            case .gpsButtonTapped:
                state.isFollowingUserLocation.toggle()
                // Following이 켜지면 친구 포커싱 해제
                if state.isFollowingUserLocation {
                    state.focusedFriendID = nil
                }
                return .none

            // MARK: 사용자 위치 업데이트
            case let .userLocationUpdated(coordinate):
                state.userLocation = UserLocationViewStateMapper.map(from: coordinate)
                return .none

            // MARK: 지도 제스처 감지 - GPS Following 해제
            case .mapGestureDetected:
                state.isFollowingUserLocation = false
                return .none
                
            // MARK: 친구 목록 버튼
            case .friendListButtonTapped:
                state.friendList = FriendListFeature.State()
                return .none
                
            case .friendList(.presented(.delegate(.friendAdded))):
                state.shouldRefresh = true
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
