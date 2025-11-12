//
//  FeedItemView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI
import Kingfisher

struct FeedItemView: View {
    let feed: SelfieFeedItem
    let displayedReactions: [ReactionViewState]
    let hiddenReactions: [ReactionViewState]
    let extraReactionCount: Int
    let onTapReaction: (ReactionViewState) -> Void
    let onLongPressReaction: (ReactionViewState) -> Void
    let onTapAddReaction: () -> Void
    let onEditTapped: () -> Void
    let onDeleteTapped: () -> Void
    let onSaveImageTapped: () -> Void
    let onReportTapped: () -> Void
    let onImageTapped: () -> Void

    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainSection
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: Main Section
private extension FeedItemView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        VStack(spacing: 12) {
            profileSection
            feedImageSection
            reactionBar
        }
        .padding(.horizontal, 20)
    }
    
    /// 프로필 섹션
    var profileSection: some View {
        HStack(spacing: 8) {
            ProfileImageView(
                image: Image(.profilePlaceholder),
                imageURL: feed.profileImageURL,
                style: .plain,
                size: .small
            )
            TypographyText(text: feed.userName, style: .t2_500, color: .gray900)
            TypographyText(text: feed.relativeTimeText, style: .b2_400, color: .gray500)
            Spacer()
            Button {
                withAnimation(.easeInOut) { showMenu.toggle() }
            } label: {
                Image(.more, size: .medium)
                    .renderingMode(.template)
                    .foregroundColor(.gray800)
            }
        }
        .zIndex(5)
        .contentShape(Rectangle())
        .overlay(alignment: .topTrailing) {
            if showMenu {
                if feed.isMyFeed {
                    myFeedMenu
                } else {
                    otherFeedMenu
                }
            }
        }
    }
    
    /// 유저 피드 메뉴
    var myFeedMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation { showMenu = false }
                onEditTapped()
            } label: {
                menuRow("수정하기")
            }
            
            divider
            
            Button {
                withAnimation { showMenu = false }
                onDeleteTapped()
            } label: {
                menuRow("삭제하기")
            }
            
            divider
            
            Button {
                withAnimation { showMenu = false }
                onSaveImageTapped()
            } label: {
                menuRow("이미지 저장")
            }
        }
        .menuContainerStyle()
    }
    
    /// 다른 유저 피드 메뉴
    var otherFeedMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation { showMenu = false }
                onReportTapped()
            } label: {
                menuRow("게시물 신고")
            }
        }
        .menuContainerStyle()
    }
    
    /// 공통 메뉴 행
    func menuRow(_ text: String) -> some View {
        TypographyText(text: text, style: .b2_400, color: .gray700)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
    }
    
    /// 구분선
    var divider: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(Color.gray50)
    }
    
    /// 피드 이미지 섹션
    var feedImageSection: some View {
        ZStack(alignment: .bottom) {
            // 피드 이미지
            if let urlString = feed.imageURL, let url = URL(string: urlString) {
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
        .contentShape(Rectangle())
        .onTapGesture {
            onImageTapped()
        }
    }
    
    /// 달리기 정보 오버레이
    var runningInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                TypographyText(text: feed.dateText, style: .c1_400, color: .gray0)
                TypographyText(text: "·", style: .c1_400, color: .gray0)
                TypographyText(text: feed.timeText, style: .c1_400, color: .gray0)
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
                    metricRow(title: "달린 거리", value: feed.totalDistanceText)
                    metricRow(title: "달린 시간", value: feed.totalRunTimeText)
                }
                HStack {
                    metricRow(title: "평균 페이스", value: feed.averagePaceText)
                    metricRow(title: "평균 케이던스", value: "\(feed.cadence) spm")
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
            displayedReactions: displayedReactions,
            hiddenReactions: hiddenReactions,
            extraReactionCount: extraReactionCount,
            onTapReaction: onTapReaction,
            onLongPressReaction: onLongPressReaction,
            onTapAddReaction: onTapAddReaction
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

private extension View {
    func menuContainerStyle() -> some View {
        self
            .frame(width: 144)
            .background(Color.gray0)
            .cornerRadius(12)
            .shadow(color: Color.gray900.opacity(0.15), radius: 12, x: 0, y: 2)
            .offset(x: 0, y: 28)
            .transition(.opacity)
            .zIndex(10)
    }
}
