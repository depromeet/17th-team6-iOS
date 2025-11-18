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
    let onProfileTapped: () -> Void

    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainSection
        }
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
            
            Menu {
                if feed.isMyFeed {
                    Button("수정하기")   { onEditTapped() }
                    Button("삭제하기")   { onDeleteTapped() }
                    Button("이미지 저장") { onSaveImageTapped() }
                } else {
                    Button("게시물 신고") { onReportTapped() }
                }
            } label: {
                Image(.more, size: .medium)
                    .renderingMode(.template)
                    .foregroundColor(.gray800)
            }
            .menuStyle(.button)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onProfileTapped()
        }
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
