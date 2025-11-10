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

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        /// 현재 표시 중인 피드 아이템
        var feed: SelfieFeedItem
        
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
            let formatter = ISO8601DateFormatter()
            
            // 새로운 리액션(=1회 반응)과 누적된 리액션을 구분
            let newReactions = feed.reactions.filter { $0.totalCount == 1 }
            let existingReactions = feed.reactions.filter { $0.totalCount > 1 }
            
            // 새로운 리액션은 반응 시각을 기준으로 최신순 정렬
            let sortedNew = newReactions.sorted { lhs, rhs in
                let lhsDate = lhs.users.compactMap { formatter.date(from: $0.reactedAtText) }.max() ?? .distantPast
                let rhsDate = rhs.users.compactMap { formatter.date(from: $0.reactedAtText) }.max() ?? .distantPast
                return lhsDate > rhsDate
            }
            // 새로 추가된 리액션을 앞에, 기존 리액션을 뒤에 붙여 최대 3개만 노출
            return Array((sortedNew + existingReactions).prefix(3))
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
        /// 네트워크 에러 팝업 액션
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        
        /// 서버 에러 액션
        case serverError(ServerErrorFeature.Action)
        
        /// 리액션 상세 시트 액션
        case reactionDetail(ReactionDetailSheetFeature.Action)
        
        /// 리액션 추가 피커 시트 액션
        case reactionPicker(ReactionPickerSheetFeature.Action)
        
        /// 리액션 탭 (이미 존재하는 리액션을 토글)
        case reactionTapped(ReactionViewState)
        
        /// 리액션 탭 서버 응답 성공
        case reactionSuccess(SelfieFeedReaction)
        
        /// 리액션 탭 서버 응답 실패
        case reactionFailure(APIError)
        
        /// 리액션 롱탭 (상세 시트 표시)
        case reactionLongPressed(ReactionViewState)
        
        /// 리액션 추가 버튼 탭
        case addReactionTapped
        
        /// 리액션 추가 서버 응답 성공
        case addReactionSuccess(SelfieFeedReaction)
        
        /// 리액션 추가 서버 응답 실패
        case addReactionFailure(APIError)
        
        /// 피드 수정 버튼 탭
        case editButtonTapped
        
        /// 피드 삭제 버튼 탭
        case deleteButtonTapped
        
        /// 피드 삭제 응답 성공
        case deleteFeedSuccess
        
        /// 피드 삭제 응답 실패
        case deleteFeedFailure(APIError)
        
        /// 이미지 저장 버튼 탭
        case saveImageButtonTapped
        
        /// 시트 전체 닫기
        case dismissSheet
        
        /// 상단 뒤로가기 버튼 탭
        case backButtonTapped
        
        /// 수정 화면 액션
        case editMyFeedDetail(PresentationAction<EditMyFeedDetailFeature.Action>)
        
        /// 상위 피처로 전달되는 delegate 이벤트
        enum Delegate: Equatable { case feedUpdated(imageURL: String) }
        case delegate(Delegate)
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        // MARK: - 하위 피처 연결
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }
        Scope(state: \.reactionDetail, action: \.reactionDetail) { ReactionDetailSheetFeature() }
        Scope(state: \.reactionPicker, action: \.reactionPicker) { ReactionPickerSheetFeature() }
        
        Reduce { state, action in
            switch action {
                
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
                return .none
                
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
                return .none
                
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
            case let .editMyFeedDetail(.presented(.delegate(.updateCompleted(imageURL)))):
                // 수정 완료 시 임시 로컬 이미지 저장
                state.feed.imageURL = imageURL
                // 수정 화면 닫기
                state.editMyFeedDetail = nil
                // 상위 피처에 feed 갱신 요청 알림
                return .send(.delegate(.feedUpdated(imageURL: imageURL)))
                
            // MARK: - 수정 화면에서 뒤로가기
            case .editMyFeedDetail(.presented(.backButtonTapped)):
                state.editMyFeedDetail = nil
                return .none
                
            // MARK: - 피드 삭제 버튼 탭
            case .deleteButtonTapped:
                let feedId = state.feed.feedID
                
                // 삭제 요청 수행
                return .run { send in
                    do {
                        _ = try await selfieFeedDeleteUseCase.execute(feedId: feedId)
                        await send(.deleteFeedSuccess)
                    } catch {
                        if let apiError = error as? APIError {
                            await send(.deleteFeedFailure(apiError))
                        } else {
                            await send(.deleteFeedFailure(.unknown))
                        }
                    }
                }
                
            // MARK: - 피드 삭제 성공
            case .deleteFeedSuccess:
                return .send(.backButtonTapped)
                
            // MARK: - 피드 삭제 실패
            case let .deleteFeedFailure(apiError):
                state.lastFailedRequest = .deleteFeed
                return handleAPIError(apiError)

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
                    return .send(.deleteButtonTapped)
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
        var updatedReactions = reactions.map { item -> ReactionViewState in
            var updated = item
            if item.emojiType == emoji {
                if item.isReactedByMe {
                    // 이미 내가 누른 상태 → 취소
                    updated.isReactedByMe = false
                    updated.totalCount = max(0, item.totalCount - 1)
                    updated.users.removeAll(where: { $0.isMe })
                } else {
                    // 새로 리액션 추가
                    updated.isReactedByMe = true
                    updated.totalCount += 1
                    updated.users.append(Self.makeMyReactionUser())
                }
            }
            return updated
        }
        // totalCount가 0이 된 리액션은 제거
        updatedReactions.removeAll(where: { $0.totalCount == 0 })
        return updatedReactions
    }
    
    /// 피커에서 선택된 리액션을 추가하거나 토글합니다.
    /// - 이미 존재하면 토글, 없으면 새로 추가합니다.
    static func addOrToggleReaction(in reactions: [ReactionViewState], emoji: EmojiType) -> [ReactionViewState] {
        var updatedReactions = reactions
        if let index = updatedReactions.firstIndex(where: { $0.emojiType == emoji }) {
            // 이미 존재하는 리액션 → 토글
            var updated = updatedReactions[index]
            if updated.isReactedByMe {
                updated.isReactedByMe = false
                updated.totalCount = max(0, updated.totalCount - 1)
                updated.users.removeAll(where: { $0.isMe })
            } else {
                updated.isReactedByMe = true
                updated.totalCount += 1
                updated.users.append(Self.makeMyReactionUser())
            }
            updatedReactions[index] = updated
        } else {
            // 존재하지 않는 리액션 → 새로 추가
            let newReaction = ReactionViewState(
                emojiType: emoji,
                totalCount: 1,
                isReactedByMe: true,
                users: [Self.makeMyReactionUser()]
            )
            updatedReactions.append(newReaction)
        }
        // totalCount가 0이 된 리액션은 제거
        updatedReactions.removeAll(where: { $0.totalCount == 0 })
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
