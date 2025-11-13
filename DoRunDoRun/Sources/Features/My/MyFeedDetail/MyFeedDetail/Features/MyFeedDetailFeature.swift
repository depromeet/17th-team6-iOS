//
//  MyFeedDetailFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct MyFeedDetailFeature {
    // MARK: - Dependencies
    /// 리액션 관련 서버 통신을 담당하는 유즈케이스
    @Dependency(\.selfieFeedReactionUseCase) var selfieFeedReactionUseCase
    /// 피드 삭제 유즈케이스
    @Dependency(\.selfieFeedDeleteUseCase) var selfieFeedDeleteUseCase
    
    @Dependency(\.selfieFeedDetailUseCase) var selfieFeedDetailUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        /// 전달받은 feedId
        var feedId: Int
        
        /// 현재 표시 중인 피드 아이템
        var feed: SelfieFeedItem
        
        /// 토스트 상태
        var toast = ToastFeature.State()
        
        /// 팝업 상태
        var popup = PopupFeature.State()
        
        /// 네트워크 에러 팝업 상태
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        
        /// 서버 에러 상태
        var serverError = ServerErrorFeature.State()
        
        /// 리액션 상세 시트 상태
        var reactionDetail = ReactionDetailSheetFeature.State()
        
        /// 리액션 추가(피커) 시트 상태
        var reactionPicker = ReactionPickerSheetFeature.State()
        
        /// 리액션 상세 시트 표시 여부
        var isReactionDetailPresented = false
        
        /// 리액션 추가 시트 표시 여부
        var isReactionPickerPresented = false
        
        /// 상단에 표시할 최대 3개의 리액션 (최근 + 많이 사용된 순)
        var displayedReactions: [ReactionViewState] {
            // 유틸리티 함수에서 내가 누른 리액션을 feed.reactions의 0번째 인덱스로 이동시켰기 때문에
            // 여기서는 상위 3개만 가져오면 됩니다.
            return Array(feed.reactions.prefix(3))
        }
        
        /// 표시되지 않는 나머지 리액션 개수
        var extraReactionCount: Int {
            max(0, feed.reactions.count - 3)
        }
        
        /// 숨겨진 리액션 목록 (상세 시트에서 표시)
        var hiddenReactions: [ReactionViewState] {
            Array(feed.reactions.dropFirst(3))
        }
        
        /// API 요청 실패 시, 어떤 요청이 실패했는지 저장하여 재시도 시 사용
        enum FailedRequestType: Equatable {
            case toggleReaction(ReactionViewState)
            case addReaction(EmojiType)
            case deleteFeed
        }
        var lastFailedRequest: FailedRequestType? = nil
        
        /// 피드 수정 화면 상태 (Sheet Navigation)
        @Presents var editMyFeedDetail: EditMyFeedDetailFeature.State?
    }
    
    // MARK: - Action
    enum Action: Equatable {
        /// 토스트 액션
        case toast(ToastFeature.Action)
        
        /// 팝업 액션
        case popup(PopupFeature.Action)
        
        /// 네트워크 에러 팝업 액션
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        
        /// 서버 에러 액션
        case serverError(ServerErrorFeature.Action)
        
        case onAppear
        case loadDetailSuccess(SelfieFeedDetailResult)
        case loadDetailFailure(APIError)
        
        /// 리액션 상세 시트 액션
        case reactionDetail(ReactionDetailSheetFeature.Action)
        
        /// 리액션 추가 피커 시트 액션
        case reactionPicker(ReactionPickerSheetFeature.Action)
        
        /// 리액션 탭 (이미 존재하는 리액션을 토글)
        case reactionTapped(ReactionViewState)
        
        /// 리액션 탭 서버 응답 성공
        case reactionSuccess(SelfieFeedReactionResult)
        
        /// 리액션 탭 서버 응답 실패
        case reactionFailure(APIError)
        
        /// 리액션 롱탭 (상세 시트 표시)
        case reactionLongPressed(ReactionViewState)
        
        /// 리액션 추가 버튼 탭
        case addReactionTapped
        
        /// 리액션 추가 서버 응답 성공
        case addReactionSuccess(SelfieFeedReactionResult)
        
        /// 리액션 추가 서버 응답 실패
        case addReactionFailure(APIError)
        
        /// 피드 수정 버튼 탭
        case editButtonTapped
        
        /// 피드 삭제 팝업
        case showDeletePopup(Int)
        
        /// 삭제 액션 처리
        case confirmDelete(Int)
        
        /// 피드 삭제 응답 성공
        case deleteFeedSuccess(Int)
        
        /// 피드 삭제 응답 실패
        case deleteFeedFailure(APIError)
        
        /// 피드 이미지 저장 버튼 탭
        case saveImageButtonTapped
        
        /// 피드 이미지 저장 성공
        case saveImageSuccess
        
        /// 피드 신고 팝업
        case showReportPopup(Int)
        
        /// 신고 액션 처리
        case confirmReport(Int)
        
        /// 시트 전체 닫기
        case dismissSheet
        
        /// 상단 뒤로가기 버튼 탭
        case backButtonTapped
        
        /// 수정 화면 액션
        case editMyFeedDetail(PresentationAction<EditMyFeedDetailFeature.Action>)
        
        /// 상위 피처로 전달되는 delegate 이벤트
        enum Delegate: Equatable {
            case feedUpdated(feedID: Int, imageURL: String?)
            case feedDeleted(feedID: Int)
            case reactionUpdated(feedID: Int, reactions: [ReactionViewState])
        }
        case delegate(Delegate)
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        // MARK: - 하위 피처 연결
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }
        Scope(state: \.reactionDetail, action: \.reactionDetail) { ReactionDetailSheetFeature() }
        Scope(state: \.reactionPicker, action: \.reactionPicker) { ReactionPickerSheetFeature() }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // empty면 상세 호출
                if state.feed.totalDistanceText.isEmpty {
                    return .run { [feedId = state.feedId] send in
                        do {
                            let detail = try await selfieFeedDetailUseCase.execute(feedId: feedId)
                            await send(.loadDetailSuccess(detail))
                        } catch {
                            if let apiError = error as? APIError {
                                await send(.loadDetailFailure(apiError))
                            } else {
                                await send(.loadDetailFailure(.unknown))
                            }
                        }
                    }
                }
                return .none

            case let .loadDetailSuccess(detail):
                state.feed = SelfieFeedDetailItemMapper.map(from: detail)
                return .none
                
            case let .loadDetailFailure(apiError):
                return handleAPIError(apiError)
                
                // MARK: - 리액션 탭 (기존 리액션 토글)
            case let .reactionTapped(reaction):
                let feedId = state.feed.feedID
                
                // 서버 요청 (성공 시 reactionSuccess로 처리)
                return .run { send in
                    do {
                        let result = try await selfieFeedReactionUseCase.execute(
                            feedId: feedId,
                            emojiType: reaction.emojiType.rawValue
                        )
                        await send(.reactionSuccess(result))
                    } catch {
                        if let apiError = error as? APIError {
                            await send(.reactionFailure(apiError))
                        } else {
                            await send(.reactionFailure(.unknown))
                        }
                    }
                }
                
                // MARK: - 리액션 토글 성공 (UI 업데이트)
            case let .reactionSuccess(result):
                state.feed.reactions = MyFeedDetailFeature.toggleReaction(
                    in: state.feed.reactions,
                    for: result.emojiType
                )
                return .send(.delegate(.reactionUpdated(
                    feedID: state.feed.feedID,
                    reactions: state.feed.reactions
                )))
                
                // MARK: - 리액션 토글 실패
            case let .reactionFailure(apiError):
                // 마지막 실패 요청 저장 → 재시도 버튼 클릭 시 사용
                state.lastFailedRequest = .toggleReaction(state.feed.reactions.first(where: { $0.isReactedByMe }) ?? .init(emojiType: .heart, totalCount: 0, isReactedByMe: false, users: []))
                return handleAPIError(apiError)
                
                // MARK: - 리액션 롱탭 (상세 시트 표시)
            case let .reactionLongPressed(reaction):
                state.isReactionDetailPresented = true
                state.reactionDetail = .init(
                    isPresented: true,
                    reactions: state.feed.reactions,
                    initialEmoji: reaction.emojiType
                )
                return .none
                
                // MARK: - 리액션 상세 시트 닫기
            case .reactionDetail(.dismissRequested):
                state.isReactionDetailPresented = false
                return .none
                
                // MARK: - 리액션 추가 버튼 탭 (피커 표시)
            case .addReactionTapped:
                state.isReactionPickerPresented = true
                return .none
                
                // MARK: - 피커에서 리액션 선택 시
            case let .reactionPicker(.reactionSelected(emoji)):
                state.isReactionPickerPresented = false
                
                let feedId = state.feed.feedID
                
                // 서버 요청 (성공 시 addReactionSuccess로 처리)
                return .run { send in
                    do {
                        let result = try await selfieFeedReactionUseCase.execute(
                            feedId: feedId,
                            emojiType: emoji.rawValue
                        )
                        await send(.addReactionSuccess(result))
                    } catch {
                        if let apiError = error as? APIError {
                            await send(.addReactionFailure(apiError))
                        } else {
                            await send(.addReactionFailure(.unknown))
                        }
                    }
                }
                
                // MARK: - 리액션 추가 성공 (UI 업데이트)
            case let .addReactionSuccess(result):
                state.feed.reactions = MyFeedDetailFeature.addOrToggleReaction(
                    in: state.feed.reactions,
                    emoji: result.emojiType
                )
                return .send(.delegate(.reactionUpdated(
                    feedID: state.feed.feedID,
                    reactions: state.feed.reactions
                )))
                
                // MARK: - 리액션 추가 실패
            case let .addReactionFailure(apiError):
                if let pickerEmoji = state.reactionPicker.selectedEmoji {
                    state.lastFailedRequest = .addReaction(pickerEmoji)
                }
                return handleAPIError(apiError)
                
                // MARK: - 수정 버튼 탭
            case .editButtonTapped:
                // 피드 수정 화면으로 이동
                state.editMyFeedDetail = EditMyFeedDetailFeature.State(feed: state.feed)
                return .none
                
                // MARK: - 수정 완료 후 delegate 처리
            case let .editMyFeedDetail(.presented(.delegate(.updateCompleted(_, imageURL)))):
                state.feed.imageURL = imageURL
                state.editMyFeedDetail = nil
                return .send(.delegate(.feedUpdated(feedID: state.feed.feedID, imageURL: imageURL)))
                
                // MARK: - 수정 화면에서 뒤로가기
            case .editMyFeedDetail(.presented(.backButtonTapped)):
                state.editMyFeedDetail = nil
                return .none
                
            case let .showDeletePopup(feedID):
                return .send(
                    .popup(.show(
                        action: .deleteFeed(feedID),
                        title: "해당 게시물을 삭제할까요?",
                        message: "한 번 삭제되면 복구하기 어려워요.",
                        actionTitle: "삭제하기",
                        cancelTitle: "취소"
                    ))
                )
                
            case let .confirmDelete(feedID):
                return .run { send in
                    do {
                        _ = try await selfieFeedDeleteUseCase.execute(feedId: feedID)
                        await send(.deleteFeedSuccess(feedID))
                    } catch {
                        await send(.deleteFeedFailure(error as? APIError ?? .unknown))
                    }
                }
                
            case .deleteFeedSuccess:
                return .merge(
                    .send(.delegate(.feedDeleted(feedID: state.feed.feedID))),
                    .send(.backButtonTapped)
                )
                
            case let .deleteFeedFailure(error):
                state.lastFailedRequest = .deleteFeed
                return handleAPIError(error)
                
            case let .showReportPopup(feedID):
                return .send(
                    .popup(.show(
                        action: .reportFeed(feedID),
                        title: "해당 게시물을 신고할까요?",
                        message: "심사를 거쳐 게시물을 삭제해드립니다.",
                        actionTitle: "신고하기",
                        cancelTitle: "취소"
                    ))
                )
                
            case let .confirmReport(feedID):
                print("신고 완료 (feedID: \(feedID))")
                return .none
                
                // MARK: - 피드 이미지 저장 버튼 탭
            case .saveImageButtonTapped:
                return .run { [feed = state.feed] send in
                    let image = await MyFeedImageCaptureView(feed: feed).snapshot()
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    await send(.saveImageSuccess)
                }
                //MARK: - 피드 이미지 저장 성공
            case .saveImageSuccess:
                return .send(.toast(.show("이미지를 저장했어요.")))
                
                // MARK: - 피커 닫기 요청
            case .reactionPicker(.dismissRequested):
                state.isReactionPickerPresented = false
                return .none
                
                // MARK: - 시트 전체 닫기
            case .dismissSheet:
                state.isReactionDetailPresented = false
                state.isReactionPickerPresented = false
                return .none
                
                // MARK: - 재시도 요청 (네트워크/서버 에러 이후)
            case .networkErrorPopup(.retryButtonTapped),
                    .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }
                
                // 실패했던 요청 유형에 따라 재전송
                switch failed {
                case let .toggleReaction(reaction):
                    return .send(.reactionTapped(reaction))
                case let .addReaction(emoji):
                    return .send(.reactionPicker(.reactionSelected(emoji)))
                case .deleteFeed:
                    return .send(.confirmDelete(state.feed.feedID))
                }
                
            default:
                return .none
            }
        }
        // MARK: - 하위 피처 연결 (Edit)
        .ifLet(\.$editMyFeedDetail, action: \.editMyFeedDetail) {
            EditMyFeedDetailFeature()
        }
    }
    
    // MARK: - 공통 에러 처리 유틸리티
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
            print(apiError.userMessage)
            return .none
        }
    }
}

// MARK: - Private Reaction Handling Logic
private extension MyFeedDetailFeature {
    /// 리액션 탭 시 상태를 토글합니다.
    /// - 이미 내가 누른 상태면 취소하고, 아니라면 추가합니다.
    static func toggleReaction(in reactions: [ReactionViewState], for emoji: EmojiType) -> [ReactionViewState] {
        var updatedReactions = reactions
        
        // 1. 대상 리액션의 인덱스를 찾습니다.
        guard let index = updatedReactions.firstIndex(where: { $0.emojiType == emoji }) else {
            // 이 액션은 이미 있는 리액션을 누를 때 발생해야 하므로, 찾지 못하면 기존 배열을 반환합니다.
            return reactions
        }
        
        var targetReaction = updatedReactions[index]
        
        if targetReaction.isReactedByMe {
            // 2. 내가 누른 상태 → 취소
            targetReaction.isReactedByMe = false
            targetReaction.totalCount = max(0, targetReaction.totalCount - 1)
            targetReaction.users.removeAll(where: { $0.isMe })
        } else {
            // 3. 내가 새로 추가 (토글이므로, 이모지 타입은 이미 존재함)
            targetReaction.isReactedByMe = true
            targetReaction.totalCount += 1
            targetReaction.users.append(Self.makeMyReactionUser())
        }
        
        // 4. 업데이트된 리액션을 기존 위치에 다시 넣거나, 카운트가 0이면 제거합니다.
        if targetReaction.totalCount > 0 {
            updatedReactions[index] = targetReaction // 순서 변경 없이 기존 위치에 업데이트
        } else {
            updatedReactions.remove(at: index) // 카운트 0이면 제거
        }
        
        return updatedReactions
    }
    
    /// 피커에서 선택된 리액션을 추가하거나 토글합니다.
    /// - 이미 존재하면 토글, 없으면 새로 추가합니다.
    static func addOrToggleReaction(in reactions: [ReactionViewState], emoji: EmojiType) -> [ReactionViewState] {
        var updatedReactions = reactions
        
        if let index = updatedReactions.firstIndex(where: { $0.emojiType == emoji }) {
            // 1. 이미 존재하는 리액션 → 순서 유지
            var targetReaction = updatedReactions[index]
            
            // 기존 로직과 동일하게 토글 처리
            if targetReaction.isReactedByMe {
                // 1-1. 내가 이미 누른 상태 → 취소
                targetReaction.isReactedByMe = false
                targetReaction.totalCount = max(0, targetReaction.totalCount - 1)
                targetReaction.users.removeAll(where: { $0.isMe })
                
                if targetReaction.totalCount > 0 {
                    updatedReactions[index] = targetReaction // 순서 유지하며 업데이트
                } else {
                    updatedReactions.remove(at: index) // 카운트 0이면 제거
                }
                
            } else {
                // 1-2. 다른 사람이 누른 상태 → 내가 추가
                targetReaction.isReactedByMe = true
                targetReaction.totalCount += 1
                targetReaction.users.append(Self.makeMyReactionUser())
                updatedReactions[index] = targetReaction // 순서 유지하며 업데이트
            }
            
        } else {
            // 2. 존재하지 않는 리액션 → 새로 생성하여 가장 앞에 추가
            let newReaction = ReactionViewState(
                emojiType: emoji,
                totalCount: 1,
                isReactedByMe: true,
                users: [Self.makeMyReactionUser()]
            )
            updatedReactions.insert(newReaction, at: 0) // 요청에 따라 가장 앞에 삽입
        }
        
        return updatedReactions
    }
    
    /// 현재 유저의 리액션 정보를 생성합니다.
    /// - 본인 정보(UserManager)를 기반으로 새 ReactionUserViewState 생성
    static func makeMyReactionUser() -> ReactionUserViewState {
        ReactionUserViewState(
            id: UserManager.shared.userId,
            nickname: UserManager.shared.nickname,
            profileImageUrl: UserManager.shared.profileImageURL,
            isMe: true,
            reactedAtText: ISO8601DateFormatter().string(from: Date())
        )
    }
}
