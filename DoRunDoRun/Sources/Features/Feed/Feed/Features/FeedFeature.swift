import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FeedFeature {
    // MARK: - Dependencies
    @Dependency(\.selfieWeekUseCase) var selfieWeekUseCase
    @Dependency(\.selfieUserUseCase) var selfieUserUseCase
    @Dependency(\.selfieFeedsUseCase) var selfieFeedsUseCase
    @Dependency(\.selfieFeedReactionUseCase) var selfieFeedReactionUseCase
    @Dependency(\.selfieFeedDeleteUseCase) var selfieFeedDeleteUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var selectedDate: Date = Date()
        var weekDates: [Date] = []
        var weekCounts: [SelfieWeekCountResult] = []

        // 인증 유저 관련
        var selfieUsers: [SelfieUserViewState] = []
        var isLoadingUsers = false

        // 피드 관련
        var feeds: [SelfieFeedItem] = []
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true

        // 리액션 관련
        var reactionDetail = ReactionDetailSheetFeature.State()
        var reactionPicker = ReactionPickerSheetFeature.State()
        var isReactionDetailPresented = false
        var isReactionPickerPresented = false
        var selectedFeedIDForReaction: Int? = nil

        // 토스트 & 팝업 & 에러
        var toast = ToastFeature.State()
        var popup = PopupFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        
        // 실패한 로직 저장
        enum FailedRequestType: Equatable {
            case fetchWeekCounts(startDate: String, endDate: String)
            case fetchSelfieUsers(String)
            case fetchSelfieFeeds(page: Int)
            case toggleReaction(feedID: Int, emoji: EmojiType)
            case addReaction(feedID: Int, emoji: EmojiType)
            case deleteFeed(Int)
        }
        var lastFailedRequest: FailedRequestType? = nil


        // Navigation
        @Presents var selectSession: SelectSessionFeature.State?
        @Presents var editMyFeedDetail: EditMyFeedDetailFeature.State?
        @Presents var certificationList: FeedCertificationListFeature.State?
        @Presents var friendList: FriendListFeature.State?
        @Presents var notificationList: NotificationFeature.State?
        @Presents var myFeedDetail: MyFeedDetailFeature.State?

        // MARK: - Helpers (UI 계산용)
        func displayedReactions(for feed: SelfieFeedItem) -> [ReactionViewState] {
            return Array(feed.reactions.prefix(3))
        }

        func hiddenReactions(for feed: SelfieFeedItem) -> [ReactionViewState] {
            Array(feed.reactions.dropFirst(3))
        }

        func extraReactionCount(for feed: SelfieFeedItem) -> Int {
            max(0, feed.reactions.count - 3)
        }
    }

    // MARK: - Action
    enum Action: Equatable {
        // Lifecycle
        case onAppear
        case selectDate(Date)
        case changeWeek(Int)
        
        // 주간 데이터
        case fetchWeekCounts(startDate: String, endDate: String)
        case fetchWeekCountsSuccess([SelfieWeekCountResult])
        case fetchWeekCountsFailure(APIError)

        // 유저 데이터
        case fetchSelfieUsers(String)
        case fetchSelfieUsersSuccess([SelfieUserResult])
        case fetchSelfieUsersFailure(APIError)
        
        // 인증 리스트
        case certificationSummaryTapped

        // 피드 데이터
        case fetchSelfieFeeds(page: Int)
        case fetchSelfieFeedsSuccess(SelfieFeedResult)
        case fetchSelfieFeedsFailure(APIError)
        case loadNextPageIfNeeded(currentItem: SelfieFeedItem?)
        
        // 피드 디테일
        case showFeedDetail(SelfieFeedItem)

        // 리액션
        case reactionTapped(feedID: Int, reaction: ReactionViewState)
        case reactionSuccess(SelfieFeedReactionResult)
        case reactionFailure(APIError)
        case reactionLongPressed(feedID: Int, reaction: ReactionViewState)
        case addReactionTapped(feedID: Int)
        case addReactionSuccess(SelfieFeedReactionResult)
        case addReactionFailure(APIError)

        // 시트
        case reactionDetail(ReactionDetailSheetFeature.Action)
        case reactionPicker(ReactionPickerSheetFeature.Action)
        case dismissSheet

        // 피드 수정/삭제/저장
        case editButtonTapped(feedID: Int)
        case showDeletePopup(Int)
        case confirmDelete(Int)
        case deleteFeedSuccess(Int)
        case deleteFeedFailure(APIError)
        case saveImageButtonTapped(feed: SelfieFeedItem)
        case saveImageSuccess
        
        // 신고 관련
        case showReportPopup(Int)
        case confirmReport(Int)
        
        // 피드 업로드
        case uploadButtonTapped
        
        // 친구 리스트
        case friendListButtonTapped
        
        // 알림 리스트
        case notificationButtonTapped
        
        // 토스트 & 팝업 & 에러
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        // 실패한 로직 저장
        case setLastFailedRequest(State.FailedRequestType)
        
        // Navigation
        case selectSession(PresentationAction<SelectSessionFeature.Action>)
        case editMyFeedDetail(PresentationAction<EditMyFeedDetailFeature.Action>)
        case certificationList(PresentationAction<FeedCertificationListFeature.Action>)
        case friendList(PresentationAction<FriendListFeature.Action>)
        case notificationList(PresentationAction<NotificationFeature.Action>)
        case myFeedDetail(PresentationAction<MyFeedDetailFeature.Action>)
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.reactionDetail, action: \.reactionDetail) { ReactionDetailSheetFeature() }
        Scope(state: \.reactionPicker, action: \.reactionPicker) { ReactionPickerSheetFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }
        Scope(state: \.toast, action: \.toast) { ToastFeature() }

        Reduce { state, action in
            let calendar = Calendar.current

            switch action {
            // MARK: - 초기 로드
            case .onAppear:
                if state.weekDates.isEmpty {
                    updateWeekDates(for: Date(), in: &state)
                }

                guard let start = state.weekDates.first,
                      let end = state.weekDates.last else { return .none }

                let startStr = DateFormatterManager.shared.formatAPIDateText(from: start)
                let endStr = DateFormatterManager.shared.formatAPIDateText(from: end)
                let todayStr = DateFormatterManager.shared.formatAPIDateText(from: state.selectedDate)

                return .merge(
                    .send(.fetchWeekCounts(startDate: startStr, endDate: endStr)),
                    .send(.fetchSelfieUsers(todayStr)),
                    .send(.fetchSelfieFeeds(page: 0))
                )

            // MARK: - 주차 변경
            case let .changeWeek(offset):
                guard let newDate = calendar.date(byAdding: .day, value: 7 * offset, to: state.selectedDate) else { return .none }
                updateWeekDates(for: newDate, in: &state)

                guard let start = state.weekDates.first,
                      let end = state.weekDates.last else { return .none }

                let startStr = DateFormatterManager.shared.formatAPIDateText(from: start)
                let endStr = DateFormatterManager.shared.formatAPIDateText(from: end)
                return .send(.fetchWeekCounts(startDate: startStr, endDate: endStr))

            // MARK: - 날짜 선택
            case let .selectDate(date):
                state.selectedDate = date
                state.currentPage = 0
                state.hasNextPage = true
                state.feeds = []

                let dateStr = DateFormatterManager.shared.formatAPIDateText(from: date)
                return .merge(
                    .send(.fetchSelfieFeeds(page: 0)),
                    .send(.fetchSelfieUsers(dateStr))
                )

            // MARK: - 주간 인증 개수
            case let .fetchWeekCounts(start, end):
                return .run { send in
                    do {
                        let result = try await selfieWeekUseCase.execute(startDate: start, endDate: end)
                        await send(.fetchWeekCountsSuccess(result))
                    } catch {
                        await send(.setLastFailedRequest(.fetchWeekCounts(startDate: start, endDate: end)))
                        await send(.fetchWeekCountsFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .fetchWeekCountsSuccess(result):
                state.weekCounts = result
                return .none

            case let .fetchWeekCountsFailure(error):
                return handleAPIError(error)

            // MARK: - 인증 유저
            case let .fetchSelfieUsers(date):
                state.isLoadingUsers = true
                return .run { send in
                    do {
                        let users = try await selfieUserUseCase.execute(date: date)
                        await send(.fetchSelfieUsersSuccess(users))
                    } catch {
                        await send(.setLastFailedRequest(.fetchSelfieUsers(date)))
                        await send(.fetchSelfieUsersFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .fetchSelfieUsersSuccess(users):
                state.isLoadingUsers = false
                state.selfieUsers = SelfieUserViewStateMapper.mapList(from: users)
                return .none

            case let .fetchSelfieUsersFailure(error):
                state.isLoadingUsers = false
                return handleAPIError(error)
                
            // MARK: - 인증 리스트
            case .certificationSummaryTapped:
                state.certificationList = .init(users: state.selfieUsers)
                return .none
                
            case .certificationList(.presented(.backButtonTapped)):
                state.certificationList = nil
                return .none

            // MARK: - 피드 목록
            case let .fetchSelfieFeeds(page):
                state.isLoading = true
                let dateStr = DateFormatterManager.shared.formatAPIDateText(from: state.selectedDate)
                return .run { [page, dateStr] send in
                    do {
                        let result = try await selfieFeedsUseCase.execute(currentDate: dateStr, userId: nil, page: page, size: 20)
                        await send(.fetchSelfieFeedsSuccess(result))
                    } catch {
                        await send(.setLastFailedRequest(.fetchSelfieFeeds(page: page)))
                        await send(.fetchSelfieFeedsFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .fetchSelfieFeedsSuccess(result):
                state.isLoading = false
                guard !result.feeds.isEmpty else {
                    state.hasNextPage = false
                    return .none
                }

                let mapped = SelfieFeedItemMapper.mapList(from: result.feeds)
                if state.currentPage == 0 {
                    state.feeds = mapped
                } else {
                    let newItems = mapped.filter { newItem in
                        !state.feeds.contains(where: { $0.feedID == newItem.feedID })
                    }
                    state.feeds.append(contentsOf: newItems)
                }
                state.currentPage += 1
                return .none

            case let .fetchSelfieFeedsFailure(error):
                state.isLoading = false
                return handleAPIError(error)

            // MARK: - 무한 스크롤
            case let .loadNextPageIfNeeded(currentItem):
                guard let currentItem,
                      !state.isLoading,
                      state.hasNextPage,
                      let index = state.feeds.firstIndex(where: { $0.feedID == currentItem.feedID })
                else { return .none }

                let threshold = max(state.feeds.count - 5, 0)
                if index >= threshold {
                    return .send(.fetchSelfieFeeds(page: state.currentPage + 1))
                }
                return .none
                
            // MARK: - 피드 디테일
            case let .showFeedDetail(feed):
                state.myFeedDetail = .init(feedId: feed.feedID, feed: feed)
                return .none

            case .myFeedDetail(.presented(.delegate(.feedDeleted(let feedID)))):
                state.feeds.removeAll(where: { $0.feedID == feedID })
                return .none

            case .myFeedDetail(.presented(.delegate(.feedUpdated(let feedID, let imageURL)))):
                if let index = state.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feeds[index].imageURL = imageURL
                }
                return .none
                
            case .myFeedDetail(.presented(.delegate(.reactionUpdated(let feedID, let reactions)))):
                if let index = state.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feeds[index].reactions = reactions
                }
                return .none
                
            case .myFeedDetail(.presented(.backButtonTapped)):
                state.myFeedDetail = nil
                return .none


            // MARK: - 리액션
            case let .reactionTapped(feedID, reaction):
                return .run { send in
                    do {
                        let result = try await selfieFeedReactionUseCase.execute(feedId: feedID, emojiType: reaction.emojiType.rawValue)
                        await send(.reactionSuccess(result))
                    } catch {
                        await send(.setLastFailedRequest(.toggleReaction(feedID: feedID, emoji: reaction.emojiType)))
                        await send(.reactionFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .reactionSuccess(result):
                if let index = state.feeds.firstIndex(where: { $0.feedID == result.selfieId }) {
                    state.feeds[index].reactions = Self.toggleReaction(
                        in: state.feeds[index].reactions, for: result.emojiType
                    )
                }
                return .none

            case let .reactionFailure(error):
                return handleAPIError(error)

            case let .reactionLongPressed(feedID, reaction):
                state.isReactionDetailPresented = true
                state.reactionDetail = .init(
                    isPresented: true,
                    reactions: state.feeds.first(where: { $0.feedID == feedID })?.reactions ?? [],
                    initialEmoji: reaction.emojiType
                )
                return .none

            // MARK: - 시트 닫기
            case .reactionDetail(.dismissRequested),
                 .reactionPicker(.dismissRequested),
                 .dismissSheet:
                withAnimation(.easeInOut(duration: 0.3)) {
                    state.isReactionDetailPresented = false
                    state.isReactionPickerPresented = false
                }
                return .none

            // MARK: - 리액션 추가
            case let .addReactionTapped(feedID):
                state.isReactionPickerPresented = true
                state.selectedFeedIDForReaction = feedID
                return .none

            case let .reactionPicker(.reactionSelected(emoji)):
                state.isReactionPickerPresented = false
                guard let feedID = state.selectedFeedIDForReaction else { return .none } 
                return .run { send in
                    do {
                        let result = try await selfieFeedReactionUseCase.execute(feedId: feedID, emojiType: emoji.rawValue)
                        await send(.addReactionSuccess(result))
                    } catch {
                        await send(.setLastFailedRequest(.addReaction(feedID: feedID, emoji: emoji)))
                        await send(.addReactionFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .addReactionSuccess(result):
                if let index = state.feeds.firstIndex(where: { $0.feedID == result.selfieId }) {
                    state.feeds[index].reactions = Self.addOrToggleReaction(
                        in: state.feeds[index].reactions, emoji: result.emojiType
                    )
                }
                return .none

            case let .addReactionFailure(error):
                return handleAPIError(error)

            // MARK: - 수정 / 삭제 / 저장
            case let .editButtonTapped(feedID):
                guard let feed = state.feeds.first(where: { $0.feedID == feedID }) else { return .none }
                state.editMyFeedDetail = .init(feed: feed)
                return .none

            case let .editMyFeedDetail(.presented(.delegate(.updateCompleted(feedID, imageURL)))):
                if let index = state.feeds.firstIndex(where: { $0.feedID == feedID }) {
                    state.feeds[index].imageURL = imageURL
                }
                state.editMyFeedDetail = nil
                return .none
                
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
                        await send(.setLastFailedRequest(.deleteFeed(feedID)))
                        await send(.deleteFeedFailure(error as? APIError ?? .unknown))
                    }
                }

            case let .deleteFeedSuccess(feedID):
                state.feeds.removeAll(where: { $0.feedID == feedID })
                if let myIndex = state.selfieUsers.firstIndex(where: { $0.isMe }) {
                    state.selfieUsers.remove(at: myIndex)
                }
                return .none

            case let .deleteFeedFailure(error):
                return handleAPIError(error)

            case let .saveImageButtonTapped(feed):
                return .run { send in
                    let image = await MyFeedImageCaptureView(feed: feed).snapshot()
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    await send(.saveImageSuccess)
                }

            case .saveImageSuccess:
                return .send(.toast(.show("이미지를 저장했어요.")))
                
            // MARK: - 게시물 신고
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
              
            // MARK: - 피드 업로드
            case .uploadButtonTapped:
                state.selectSession = .init()
                return .none
                
            case .selectSession(.presented(.delegate(.feedUploadCompleted))):
                state.selectSession = nil
                return .send(.fetchSelfieFeeds(page: 0))
                
            case .selectSession(.presented(.backButtonTapped)):
                state.selectSession = nil
                return .none
                
            // MARK: - 친구 리스트
            case .friendListButtonTapped:
                state.friendList = .init()
                return .none
                
            case .friendList(.presented(.backButtonTapped)):
                state.friendList = nil
                return .none
                
            // MARK: - 알림 리스트
            case .notificationButtonTapped:
                state.notificationList = .init()
                return .none
                
            case .notificationList(.presented(.backButtonTapped)):
                state.notificationList = nil
                return .none
                
            // MARK: - 실패한 로직 저장
            case let .setLastFailedRequest(request):
                state.lastFailedRequest = request
                return .none
                
            // MARK: - 재시도
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }
                switch failed {
                case let .fetchWeekCounts(start, end):
                    return .send(.fetchWeekCounts(startDate: start, endDate: end))
                case let .fetchSelfieUsers(date):
                    return .send(.fetchSelfieUsers(date))
                case let .fetchSelfieFeeds(page):
                    return .send(.fetchSelfieFeeds(page: page))
                case let .toggleReaction(feedID, emoji):
                    return .send(.reactionTapped(feedID: feedID, reaction: .init(emojiType: emoji, totalCount: 0, isReactedByMe: false, users: [])))
                case let .addReaction(_, emoji):
                    return .send(.reactionPicker(.reactionSelected(emoji)))
                case let .deleteFeed(feedID):
                    return .send(.confirmDelete(feedID))
                }

            default:
                return .none
            }
        }
        .ifLet(\.$selectSession, action: \.selectSession) { SelectSessionFeature() }
        .ifLet(\.$editMyFeedDetail, action: \.editMyFeedDetail) { EditMyFeedDetailFeature() }
        .ifLet(\.$certificationList, action: \.certificationList) { FeedCertificationListFeature() }
        .ifLet(\.$friendList, action: \.friendList) { FriendListFeature() }
        .ifLet(\.$notificationList, action: \.notificationList) { NotificationFeature() }
        .ifLet(\.$myFeedDetail, action: \.myFeedDetail) { MyFeedDetailFeature() }
    }
}

// MARK: - Helpers
private extension FeedFeature {
    func updateWeekDates(for date: Date, in state: inout State) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: date)!
        state.weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        state.selectedDate = date
    }

    func handleAPIError(_ apiError: APIError) -> Effect<Action> {
        switch apiError {
        case .networkError: return .send(.networkErrorPopup(.show))
        case .notFound:     return .send(.serverError(.show(.notFound)))
        case .internalServer: return .send(.serverError(.show(.internalServer)))
        case .badGateway:   return .send(.serverError(.show(.badGateway)))
        default: return .none
        }
    }
}

// MARK: - Reaction Logic
private extension FeedFeature {
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
