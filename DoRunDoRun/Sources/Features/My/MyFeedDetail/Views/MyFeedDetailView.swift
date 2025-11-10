//
//  MyFeedDetailView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct MyFeedDetailView: View {
    let store: StoreOf<MyFeedDetailFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
                sheetOverlaySection
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Server Error Section
private extension MyFeedDetailView {
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

// MARK: Main Section
private extension MyFeedDetailView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            ScrollView {
                VStack(spacing: 16) {
                    profileSection
                    feedImageSection
                    reactionBar
                }
                .padding(.horizontal, 20)
            }
            .scrollDisabled(true)
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
        }
    }
    
    /// 프로필 섹션
    var profileSection: some View {
        HStack(spacing: 8) {
            ProfileImageView(
                image: Image(.profilePlaceholder),
                imageURL: store.feed.profileImageURL,
                style: .plain,
                size: .small
            )
            TypographyText(text: store.feed.userName, style: .t2_500, color: .gray900)
            Spacer()
            Button {
                print("more tap")
            } label: {
                Image(.more, size: .medium)
            }
        }
        .padding(.top, 16)
    }
    
    /// 피드 이미지 섹션
    var feedImageSection: some View {
        ZStack(alignment: .bottom) {
            // 피드 이미지
            if let urlString = store.feed.imageURL, let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray100)
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                            .cornerRadius(16)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: (UIScreen.main.bounds.width - 40), height: (UIScreen.main.bounds.width - 40))
                    .cornerRadius(16)
            } else {
                Rectangle()
                    .fill(Color.gray100)
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(16)
            }

            // 달리기 정보
            runningInfoOverlay
        }
    }

    /// 달리기 정보 오버레이
    var runningInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                TypographyText(text: store.feed.dateText, style: .c1_400, color: .gray0)
                TypographyText(text: "·", style: .c1_400, color: .gray0)
                TypographyText(text: store.feed.timeText, style: .c1_400, color: .gray0)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.dimLight)
            .clipShape(.capsule)
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                HStack {
                    metricRow(title: "달린 거리", value: store.feed.totalDistanceText)
                    metricRow(title: "달린 시간", value: store.feed.totalRunTimeText)
                }
                HStack {
                    metricRow(title: "평균 페이스", value: store.feed.averagePaceText)
                    metricRow(title: "평균 케이던스", value: "\(store.feed.cadence) spm")
                }
            }
            .padding(.top, 80)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: 0x000000, alpha: 0.8), // 아래쪽 진한 검정
                        Color(hex: 0x000000, alpha: 0.0)  // 위쪽 완전 투명
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .cornerRadius(16)
            )
        }
    }
    
    /// 리액션 바
    var reactionBar: some View {
        ReactionBarView(
            displayedReactions: store.displayedReactions,
            hiddenReactions: store.hiddenReactions,
            extraReactionCount: store.extraReactionCount,
            onTapReaction: { store.send(.reactionTapped($0)) },
            onLongPressReaction: { store.send(.reactionLongPressed($0)) },
            onTapAddReaction: { store.send(.addReactionTapped) }
        )
    }

    /// 공통 메트릭 행
    func metricRow(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                TypographyText(text: title, style: .c1_400, color: .gray0)
                TypographyText(text: value, style: .h1_700, color: .gray0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Network Error Popup Section
private extension MyFeedDetailView {
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

// MARK: - Sheet Overlay
private extension MyFeedDetailView {
    /// Sheet Overlay
    @ViewBuilder
    var sheetOverlaySection: some View {
        ZStack(alignment: .bottom) {
            if store.isReactionDetailPresented || store.isReactionPickerPresented {
                Color.dimLight
                    .onTapGesture { store.send(.dismissSheet) }
                    .transition(.opacity)
            }

            if store.isReactionDetailPresented {
                ReactionDetailSheetView(
                    store: store.scope(state: \.reactionDetail, action: \.reactionDetail)
                )
                .transition(.move(edge: .bottom))
            }

            if store.isReactionPickerPresented {
                ReactionPickerSheetView(
                    store: store.scope(state: \.reactionPicker, action: \.reactionPicker)
                )
                .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut(duration: 0.3),
                   value: store.isReactionDetailPresented || store.isReactionPickerPresented)
    }
}
