//
//  FeedCertificationSummaryView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI
import Kingfisher

struct FeedCertificationSummaryView: View {
    let totalCount: Int
    let profileImageURLs: [String]
    let isMyIncluded: Bool
    
    private var displayURLs: [String] {
        Array(profileImageURLs.prefix(3))
    }
    
    private let profileSize: CGFloat = 25
    private let overlapOffset: CGFloat = 18
    private let badgeWidth: CGFloat = 38
    private let badgeHeight: CGFloat = 25
    private let badgeToProfileSpacing: CGFloat = 12
    
    var body: some View {
        HStack(spacing: 8) {
            // MARK: - 겹침 ZStack
            ZStack(alignment: .leading) {
                // 1. +N 배지 (가장 왼쪽, 최상단)
                badgeView
                    .zIndex(100) // 항상 제일 위
                
                // 2. 프로필 이미지들 (역순 zIndex: 왼쪽이 가장 위)
                ForEach(Array(displayURLs.enumerated()), id: \.offset) { index, url in
                    let startX = badgeWidth - overlapOffset + badgeToProfileSpacing
                    let xOffset = startX + CGFloat(index) * overlapOffset
                    
                    profileImageView(url: url)
                        .offset(x: xOffset)
                        .zIndex(Double(displayURLs.count - index)) // ← 핵심: 왼쪽이 더 높음
                }
            }
            .frame(width: calculatedWidth(), height: profileSize, alignment: .leading)
            
            // MARK: - 텍스트
            TypographyText(
                text: isMyIncluded
                ? "\(totalCount)명이 인증했어요!"
                : "‘나’를 제외한 \(totalCount)명이 인증했어요!",
                style: .b1_500,
                color: .gray700
            )
            
            Spacer()
        }
        .frame(height: 25)
        .padding(.horizontal, 20)
        .background(Color.gray0)
    }
    
    // MARK: - 배지
    private var badgeView: some View {
        TypographyText(text: "+\(totalCount)", style: .b2_500, color: .blue600)
            .padding(.vertical, 2)
            .padding(.horizontal, 7)
            .frame(width: badgeWidth, height: badgeHeight)
            .background(
                Capsule()
                    .fill(Color.blue100)
                    .overlay(Capsule().stroke(Color.gray0, lineWidth: 1))
            )
            .offset(x: 0)
    }
    
    // MARK: - 프로필 이미지
    @ViewBuilder
    private func profileImageView(url: String) -> some View {
        KFImage(URL(string: url))
            .resizable()
            .scaledToFill()
            .frame(width: profileSize, height: profileSize)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .background(Circle().fill(Color.gray100))
    }
    
    // MARK: - 너비 계산
    private func calculatedWidth() -> CGFloat {
        if displayURLs.isEmpty {
            return badgeWidth
        }
        
        let lastIndex = displayURLs.count - 1
        let lastX = badgeWidth - overlapOffset + badgeToProfileSpacing + CGFloat(lastIndex) * overlapOffset
        return lastX + profileSize
    }
}

#Preview {
    VStack(spacing: 20) {
        FeedCertificationSummaryView(
            totalCount: 1,
            profileImageURLs: ["https://picsum.photos/40"],
            isMyIncluded: true
        )
        FeedCertificationSummaryView(
            totalCount: 2,
            profileImageURLs: [
                "https://picsum.photos/41",
                "https://picsum.photos/42"
            ],
            isMyIncluded: true
        )
        FeedCertificationSummaryView(
            totalCount: 3,
            profileImageURLs: [
                "https://picsum.photos/43",
                "https://picsum.photos/44",
                "https://picsum.photos/45"
            ],
            isMyIncluded: false
        )
        FeedCertificationSummaryView(
            totalCount: 10,
            profileImageURLs: [
                "https://picsum.photos/46",
                "https://picsum.photos/47",
                "https://picsum.photos/48"
            ],
            isMyIncluded: true
        )
    }
}
