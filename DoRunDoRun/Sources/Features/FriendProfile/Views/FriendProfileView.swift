//
//  FriendProfileView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/17/25.
//

import SwiftUI
import ComposableArchitecture

struct FriendProfileView: View {
    @Perception.Bindable var store: StoreOf<FriendProfileFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
            .task { store.send(.onAppear) }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        store.send(.backButtonTapped)
                    } label: {
                        Image(.arrowLeft, size: .medium)
                            .renderingMode(.template)
                            .foregroundColor(.gray800)
                    }
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.feedDetail, action: \.feedDetail)
            ) { store in
                MyFeedDetailView(store: store)
            }
        }
    }
}

// MARK: - Server Error Section
private extension FriendProfileView {
    /// Server Error Section
    @ViewBuilder
    var serverErrorSection: some View {
        if let serverErrorType = store.serverError.serverErrorType {
            ServerErrorView(serverErrorType: serverErrorType) {
                store.send(.serverError(.retryButtonTapped))
            }
        }
    }
}

// MARK: - Main Section
private extension FriendProfileView {
    /// Main Section
    @ViewBuilder
    private var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(spacing: 0) {
                profileSection
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.gray100)
                contentSection
            }
        }
    }

    /// 프로필 섹션
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                ProfileImageView(
                    image: Image(.profilePlaceholder),
                    imageURL: store.userSummary?.profileImageURL,
                    style: .plain,
                    isZZZ: false
                )

                VStack(alignment: .leading, spacing: 2) {
                    if let userSummary = store.userSummary {
                        TypographyText(text: userSummary.name, style: .t2_700, color: .gray900)
                        TypographyText(text: "친구 \(userSummary.friendCountText)", style: .b2_500, color: .gray700)
                    }
                }

                Spacer()
            }
            HStack {
                if let userSummary = store.userSummary {
                    HStack(alignment: .center, spacing: 12) {
                        TypographyText(text: "누적 거리", style: .b2_500, color: .gray500)
                        TypographyText(text: userSummary.totalDistanceText, style: .t2_700, color: .gray900)
                    }
                    Spacer()
                    HStack(alignment: .center, spacing: 12) {
                        TypographyText(text: "인증 횟수", style: .b2_500, color: .gray500)
                        TypographyText(text: userSummary.selfieCountText, style: .t2_700, color: .gray900)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 26)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    /// 컨텐츠 섹션
    private var contentSection: some View {
        Group {
            if store.feeds.isEmpty {
                MyFeedEmptyView()
            } else {
                MyFeedView(
                    feeds: store.feeds,
                    loadNextPageIfNeeded: { feed in
                        store.send(.loadNextPageIfNeeded(currentItem: feed))
                    },
                    isLoading: store.isLoading,
                    onFeedTap: { feed in
                        store.send(.feedItemTapped(feed))
                    }
                )
            }
        }
    }
}

// MARK: - Network Error Popup Section
private extension FriendProfileView {
    /// Networ Error Popup Section
    @ViewBuilder
    var networkErrorPopupSection: some View {
        if store.networkErrorPopup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                NetworkErrorPopupView {
                    store.send(.networkErrorPopup(.retryButtonTapped))
                }
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(10)
        }
    }
}

// MARK: - Preview
#Preview {
    FriendProfileView(
        store: Store(initialState: FriendProfileFeature.State(userID: 123)) {
            FriendProfileFeature()
        }
    )
}
