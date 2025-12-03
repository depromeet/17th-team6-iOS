//
//  SessionDetailFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SessionDetailFeature {
    @Dependency(\.runSessionDetailUseCase) var runSessionDetailUseCase
    @Dependency(\.selfieUploadableUseCase) var selfieUploadableUseCase

    @ObservableState
    struct State: Equatable {
        var session: RunningSessionSummaryViewState
        var sessionId: Int
        var detail: RunningDetailViewState?
        var uploadable: SelfieUploadableViewState?
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        @Presents var createFeed: CreateFeedFeature.State?
        @Presents var myFeedDetail: FeedDetailFeature.State?
    }

    enum Action: Equatable {
        case backButtonTapped
        case onAppear

        // 세션 디테일
        case fetchDetail
        case fetchDetailSuccess(RunningDetail)
        case fetchDetailFailure(APIError)

        // 인증 업로드 가능 여부
        case fetchUploadable
        case fetchUploadableSuccess(SelfieUploadableResult)
        case fetchUploadableFailure(APIError)

        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        // CTA
        case verificationPossibleButtonTapped
        case verificationCompletedButtonTapped
        
        // Navigation
        case createFeed(PresentationAction<CreateFeedFeature.Action>)
        case myFeedDetail(PresentationAction<FeedDetailFeature.Action>)

        // Delegate
        enum Delegate: Equatable {
            case navigateToMyProfile
        }
        case delegate(Delegate)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - onAppear → 2가지 요청 병렬 실행
            case .onAppear:
                return .merge(
                    .send(.fetchDetail),
                    .send(.fetchUploadable)
                )

            // MARK: - Fetch Detail
            case .fetchDetail:
                return .run { [sessionId = state.sessionId] send in
                    do {
                        let detail = try await runSessionDetailUseCase.fetchSessionDetail(sessionId: sessionId)
                        await send(.fetchDetailSuccess(detail))
                    } catch {
                        await send(.fetchDetailFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .fetchDetailSuccess(detail):
                state.detail = RunningDetailViewStateMapper.map(from: detail)
                return .none

            case let .fetchDetailFailure(error):
                return handleAPIError(error)

            // MARK: - Fetch Uploadable
            case .fetchUploadable:
                return .run { [sessionId = state.sessionId] send in
                    do {
                        let result = try await selfieUploadableUseCase.execute(runSessionId: sessionId)
                        await send(.fetchUploadableSuccess(result))
                    } catch {
                        await send(.fetchUploadableFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .fetchUploadableSuccess(result):
                state.uploadable = SelfieUploadableViewStateMapper.map(from: result)
                return .none

            case let .fetchUploadableFailure(error):
                return handleAPIError(error)
                
            // MARK: CTA
            case .verificationCompletedButtonTapped:
                if let feed = state.detail?.feed {
                    state.myFeedDetail = FeedDetailFeature.State(feedId: feed.id, feed: .empty(feedID: feed.id))
                }
                return .none

            case .verificationPossibleButtonTapped:
                state.createFeed = CreateFeedFeature.State(session: state.session)
                return .none
                
            case .myFeedDetail(.presented(.backButtonTapped)):
                state.myFeedDetail = nil
                return .none

            case .myFeedDetail(.presented(.delegate(.navigateToMyProfile))):
                // 세션 상세에서 인증 게시물을 보고 있을 때 내 프로필을 탭하면 sheet dismiss + delegate 전달
                state.myFeedDetail = nil
                return .send(.delegate(.navigateToMyProfile))

            case .createFeed(.presented(.backButtonTapped)):
                state.createFeed = nil
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$createFeed, action: \.createFeed) { CreateFeedFeature() }
        .ifLet(\.$myFeedDetail, action: \.myFeedDetail) { FeedDetailFeature() }
    }
}

// MARK: - API Error Handler
private extension SessionDetailFeature {
    func handleAPIError(_ apiError: APIError) -> Effect<Action> {
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
            print("[API ERROR]", apiError.userMessage)
            return .none
        }
    }
}
