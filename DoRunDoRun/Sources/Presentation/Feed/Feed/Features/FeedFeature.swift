import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FeedFeature {
    // MARK: - Dependencies
    @Dependency(\.notificationUnreadCountUseCase) var notificationUnreadCountUseCase
    @Dependency(\.selfieWeekUseCase) var selfieWeekUseCase
    @Dependency(\.selfieUserUseCase) var selfieUserUseCase
    @Dependency(\.selfieFeedsUseCase) var selfieFeedsUseCase
    @Dependency(\.selfieFeedReactionUseCase) var selfieFeedReactionUseCase
    @Dependency(\.selfieFeedDeleteUseCase) var selfieFeedDeleteUseCase
    
    @Dependency(\.analyticsTracker) var analytics

    // MARK: - State
    @ObservableState
    struct State {
        // Path는 AppFeature에서 관리

        var unreadCount: Int = 0
        var selectedDate: Date = Date()
        var weekDates: [Date] = []
        var weekCounts: [SelfieWeekCountResult] = []
        var selfieUsers: [SelfieUserViewState] = []
        var isLoadingUsers = false
        var feeds: [SelfieFeedItem] = []
        var currentPage = 0
        var isLoading = false
        var hasNextPage = true
        var isReactionDetailPresented = false
        var isReactionPickerPresented = false
        var selectedFeedIDForReaction: Int? = nil
        var lastFailedRequest: FailedRequestType? = nil
        enum FailedRequestType: Equatable {
            case fetchUnreadCount
            case fetchWeekCounts(startDate: String, endDate: String)
            case fetchSelfieUsers(String)
            case fetchSelfieFeeds(page: Int)
            case toggleReaction(feedID: Int, emoji: EmojiType)
            case addReaction(feedID: Int, emoji: EmojiType)
            case deleteFeed(Int)
        }

        var reactionDetail = ReactionDetailSheetFeature.State()
        var reactionPicker = ReactionPickerSheetFeature.State()
        var toast = ToastFeature.State()
        var popup = PopupFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()

        func displayedReactions(for feed: SelfieFeedItem) -> [ReactionViewState] {
            return Array(feed.reactions.prefix(3))
        }
        func hiddenReactions(for feed: SelfieFeedItem) -> [ReactionViewState] {
            Array(feed.reactions.dropFirst(3))
        }
        func extraReactionCount(for feed: SelfieFeedItem) -> Int {
            max(0, feed.reactions.count - 3)
        }
        
        var isFabExpanded = false
    }

    // MARK: - Action
    enum Action {
        // Path는 AppFeature에서 관리

        case friendListButtonTapped
        
        case fetchUnreadCount
        case fetchUnreadCountSuccess(Int)
        case fetchUnreadCountFailure(APIError)
        case notificationButtonTapped
        
        case onAppear
        case selectDate(Date)
        
        case changeWeek(Int)
        case fetchWeekCounts(startDate: String, endDate: String)
        case fetchWeekCountsSuccess([SelfieWeekCountResult])
        case fetchWeekCountsFailure(APIError)

        case fetchSelfieUsers(String)
        case fetchSelfieUsersSuccess([SelfieUserResult])
        case fetchSelfieUsersFailure(APIError)
        case certificationSummaryTapped

        case fetchSelfieFeeds(page: Int)
        case fetchSelfieFeedsSuccess(SelfieFeedResult)
        case fetchSelfieFeedsFailure(APIError)
        case loadNextPageIfNeeded(currentItem: SelfieFeedItem?)
        
        case feedProfileTapped(feed: SelfieFeedItem)
        
        case feedImageTapped(SelfieFeedItem)
        
        case reactionTapped(feedID: Int, reaction: ReactionViewState)
        case reactionSuccess(SelfieFeedReactionResult)
        case reactionFailure(APIError)
        case reactionLongPressed(feedID: Int, reaction: ReactionViewState)
        case addReactionTapped(feedID: Int)
        case addReactionSuccess(SelfieFeedReactionResult)
        case addReactionFailure(APIError)
        case reactionDetail(ReactionDetailSheetFeature.Action)
        case reactionPicker(ReactionPickerSheetFeature.Action)
        case dismissSheet
        
        case editButtonTapped(feedID: Int)

        case showDeletePopup(Int)
        case confirmDelete(Int)
        case deleteFeedSuccess(Int)
        case deleteFeedFailure(APIError)
        
        case saveImageButtonTapped(feed: SelfieFeedItem)
        case saveImageSuccess
        
        case showReportPopup(Int)
        case confirmReport(Int)
        
        case fabTapped
        case dismissFab
        case entryMenuSelectSessionTapped
        case entryMenuEnterManualSessionTapped
        
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        case setLastFailedRequest(State.FailedRequestType)
                
        enum Delegate: Equatable {
            case feedUpdateCompleted(feedID: Int, newImageURL: String?)
            case feedDeleteCompleted(feedID: Int)
            case navigateToMyProfile

            // Navigation Delegates
            case navigateToFriendList
            case navigateToNotificationList
            case navigateToCertificationUserList(users: [SelfieUserViewState])
            case navigateToFriendProfile(userID: Int)
            case navigateToFeedDetail(feedID: Int, feed: SelfieFeedItem)
            case navigateToEditFeed(feed: SelfieFeedItem)
            case navigateToSelectSession
            case navigateToEnterManualSession
            case navigateBack
        }
        case delegate(Delegate)
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
                
            // MARK: - 친구 리스트
            case .friendListButtonTapped:
                return .send(.delegate(.navigateToFriendList))

            // MARK: - 알림 리스트
            case .notificationButtonTapped:
                return .send(.delegate(.navigateToNotificationList))
                
            // MARK: - 초기 로드
            case .onAppear:
                // event
                analytics.track(.screenViewed(.feed))
                
                if state.weekDates.isEmpty { updateWeekDates(for: Date(), in: &state) }
                
                guard let start = state.weekDates.first, let end = state.weekDates.last else { return .none }

                let startStr = DateFormatterManager.shared.formatAPIDateText(from: start)
                let endStr = DateFormatterManager.shared.formatAPIDateText(from: end)
                let todayStr = DateFormatterManager.shared.formatAPIDateText(from: state.selectedDate)

                return .merge(
                    .send(.fetchWeekCounts(startDate: startStr, endDate: endStr)),
                    .send(.fetchSelfieUsers(todayStr)),
                    .send(.fetchSelfieFeeds(page: 0)),
                    .send(.fetchUnreadCount)
                )

            // MARK: - 주차 변경
            case let .changeWeek(offset):
                guard let newDate = calendar.date(byAdding: .day, value: 7 * offset, to: state.selectedDate) else { return .none }
                updateWeekDates(for: newDate, in: &state)

                guard let start = state.weekDates.first, let end = state.weekDates.last else { return .none }

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
              
            // MARK: - 읽지 않은 알림 수 조회
            case .fetchUnreadCount:
                return .run { send in
                    do {
                        let result = try await notificationUnreadCountUseCase.execute()
                        await send(.fetchUnreadCountSuccess(result.count))
                    } catch {
                        await send(.setLastFailedRequest(.fetchUnreadCount))
                        await send(.fetchUnreadCountFailure(error as? APIError ?? .unknown))
                    }
                }
            
            // 조회 성공
            case let .fetchUnreadCountSuccess(count):
                state.unreadCount = count
                return .none

            // 조회 실패
            case let .fetchUnreadCountFailure(error):
                return handleAPIError(error)

            // MARK: - 주간 인증 개수 조회
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

            // 조회 성공
            case let .fetchWeekCountsSuccess(result):
                state.weekCounts = result
                return .none

            // 조회 실패
            case let .fetchWeekCountsFailure(error):
                return handleAPIError(error)

            // MARK: - 인증 유저 조회
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
            
            // 조회 성공
            case let .fetchSelfieUsersSuccess(users):
                state.isLoadingUsers = false
                state.selfieUsers = SelfieUserViewStateMapper.mapList(from: users)
                return .none
                
            // 조회 실패
            case let .fetchSelfieUsersFailure(error):
                state.isLoadingUsers = false
                return handleAPIError(error)
                
            // MARK: - 인증 유저 요약 탭
            case .certificationSummaryTapped:
                return .send(.delegate(.navigateToCertificationUserList(users: state.selfieUsers)))
                
            // MARK: - 피드 목록 조회
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

            // 조회 성공
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
                
                state.feeds.sort { $0.selfieDate > $1.selfieDate }
                
                return .none

            // 조회 실패
            case let .fetchSelfieFeedsFailure(error):
                state.isLoading = false
                return handleAPIError(error)

            // 페이지네이션
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
                
            // MARK: - 피드 프로필 탭
            case let .feedProfileTapped(feed):
                // 본인 프로필이면 My 탭으로 전환, 아니면 친구 프로필로 이동
                if feed.userID == UserManager.shared.userId {
                    return .send(.delegate(.navigateToMyProfile))
                } else {
                    return .send(.delegate(.navigateToFriendProfile(userID: feed.userID)))
                }

            // MARK: - 피드 이미지 탭
            case let .feedImageTapped(feed):
                return .send(.delegate(.navigateToFeedDetail(feedID: feed.feedID, feed: feed)))
                
            // MARK: - 리액션 탭
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
                
            // 리액션 추가 성공
            case let .reactionSuccess(result):
                if let index = state.feeds.firstIndex(where: { $0.feedID == result.selfieId }) {
                    state.feeds[index].reactions = Self.toggleReaction(
                        in: state.feeds[index].reactions, for: result.emojiType
                    )
                }
                return .none

            // 리액션 추가 실패
            case let .reactionFailure(error):
                return handleAPIError(error)

            // MARK: - 리액션 롱탭
            case let .reactionLongPressed(feedID, reaction):
                state.isReactionDetailPresented = true
                state.reactionDetail = .init(
                    isPresented: true,
                    reactions: state.feeds.first(where: { $0.feedID == feedID })?.reactions ?? [],
                    initialEmoji: reaction.emojiType
                )
                return .none

            // MARK: - 리액션 추가 버튼 탭
            case let .addReactionTapped(feedID):
                state.isReactionPickerPresented = true
                state.selectedFeedIDForReaction = feedID
                return .none

            // 리액션 피커 시트 내에서 리액션 선택
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

            // 리액션 피커 시트 내에서 리액션 추가 성공
            case let .addReactionSuccess(result):
                if let index = state.feeds.firstIndex(where: { $0.feedID == result.selfieId }) {
                    state.feeds[index].reactions = Self.addOrToggleReaction(
                        in: state.feeds[index].reactions, emoji: result.emojiType
                    )
                }
                return .none

            // 리액션 피커 시트 내에서 리액션 추가 실패
            case let .addReactionFailure(error):
                return handleAPIError(error)
                
            // MARK: - 리액션 상세 시트 유저 프로필 탭
            case let .reactionDetail(.delegate(.navigateToFriendProfile(userID))):
                state.isReactionDetailPresented = false
                return .send(.delegate(.navigateToFriendProfile(userID: userID)))

            case .reactionDetail(.delegate(.navigateToMyProfile)):
                state.isReactionDetailPresented = false
                return .send(.delegate(.navigateToMyProfile))

            // MARK: - 리액션 관련 시트 닫기
            case .reactionDetail(.dismissRequested),
                    .reactionPicker(.dismissRequested),
                    .dismissSheet:
                withAnimation(.easeInOut(duration: 0.3)) {
                    state.isReactionDetailPresented = false
                    state.isReactionPickerPresented = false
                }
                return .none

            // MARK: - 수정 버튼 탭
            case let .editButtonTapped(feedID):
                guard let feed = state.feeds.first(where: { $0.feedID == feedID }) else { return .none }
                return .send(.delegate(.navigateToEditFeed(feed: feed)))
                
            // MARK: - 삭제 팝업
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

            // 삭제 처리
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
                
            // 삭제 성공
            case let .deleteFeedSuccess(feedID):
                state.feeds.removeAll(where: { $0.feedID == feedID })
                if let myIndex = state.selfieUsers.firstIndex(where: { $0.isMe }) {
                    state.selfieUsers.remove(at: myIndex)
                }
                return .send(.delegate(.feedDeleteCompleted(feedID: feedID)))
                
            // 삭제 실패
            case let .deleteFeedFailure(error):
                return handleAPIError(error)

            // MARK: - 이미지 저장 버튼 탭
            case let .saveImageButtonTapped(feed):
                return .run { send in
                    let image = await FeedImageCaptureView(feed: feed).snapshot()
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    await send(.saveImageSuccess)
                }
                
            // 이미지 저장
            case .saveImageSuccess:
                return .send(.toast(.show("이미지를 저장했어요.")))
                
            // MARK: - 신고 팝업
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
            
            // 신고 처리
            case let .confirmReport(feedID):
                print("신고 완료 (feedID: \(feedID))")
                return .none
              
            // MARK: - 피드 업로드 버튼 탭
            case .fabTapped:
                state.isFabExpanded.toggle()
                return .none

            case .dismissFab:
                state.isFabExpanded = false
                return .none
                
            case .entryMenuSelectSessionTapped:
                // event
                // Entry / Upload / Result 이벤트는 CreateFeedFeature에서 처리
                analytics.track(
                    .feed(.createFeedCtaClicked(
                        source: .feedFab,
                        runningID: nil
                    ))
                )
                return .send(.delegate(.navigateToSelectSession))

            case .entryMenuEnterManualSessionTapped:
                // event
                // Entry / Upload / Result 이벤트는 CreateFeedFeature에서 처리
                analytics.track(
                    .feed(.createFeedCtaClicked(
                        source: .feedFab,
                        runningID: nil
                    ))
                )
                return .send(.delegate(.navigateToEnterManualSession))
                
            // MARK: - 실패한 로직 저장
            case let .setLastFailedRequest(request):
                state.lastFailedRequest = request
                return .none
                
            // MARK: - 재시도
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }
                switch failed {
                case .fetchUnreadCount:
                    return .send(.fetchUnreadCount)
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
