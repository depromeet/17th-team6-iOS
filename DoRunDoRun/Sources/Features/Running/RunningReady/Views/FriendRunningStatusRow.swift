//
//  FriendRunningStatusRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

/// 유저 및 친구 러닝 상태를 표시하는 리스트 행(View)
struct FriendRunningStatusRow: View {
    let status: FriendRunningStatusViewState
    let city: String
    let isFocused: Bool
    let isSent: Bool
    
    var friendTapped: (() -> Void)? = nil
    var cheerButtonTapped: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 16) {
            profileImageView
            infoSection
            Spacer()
            cheerButton
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(isFocused ? Color(hex: 0xD2DCFF).opacity(0.25) : Color.gray0)
        .onTapGesture { friendTapped?() }
    }
}

// MARK: - Subviews
private extension FriendRunningStatusRow {
    /// 프로필 이미지
    private var profileImageView: some View {
        ProfileImageView(
            image: nil,
            style: isFocused ? .blueBorder : .grayBorder,
            isZZZ: !status.isRunning
        )
    }

    /// 정보 영역 (이름, 시간, 거리, 위치)
    @ViewBuilder
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 상단 (이름 + 나 배지 + 시간)
            HStack {
                Text(status.name)
                    .typography(.t2_700)

                if status.isMe {
                    Circle()
                        .fill(Color.blue600)
                        .frame(width: 20, height: 20)
                        .overlay(Text("나").typography(.c1_700, color: .gray0))
                }

                Spacer().frame(width: 12)

                if let time = status.latestRanText {
                    Text(time)
                        .typography(.b2_500, color: .gray500)
                }
            }

            // 하단 (거리 + 위치)
            if status.isRunning, let distance = status.distanceText {
                HStack(spacing: 4) {
                    Text(distance).typography(.b2_500, color: .gray700)
                    Text("/").typography(.b2_500, color: .gray700)
                    Text(city).typography(.b2_500, color: .gray700)
                }
            } else {
                Text("아직 러닝 기록이 없어요...")
                    .typography(.b2_500, color: .gray700)
            }
        }
    }

    /// 응원 버튼
    @ViewBuilder
    private var cheerButton: some View {
        if !status.isRunning {
            AppButton(
                title: isSent ? "응원완료" : "응원하기",
                style: .primary,
                size: .small,
                isDisabled: isSent
            ) {
                cheerButtonTapped?()
            }
            .frame(width: 75)
        }
    }
}

// MARK: - Preview
#Preview {
    FriendRunningStatusRow(
        status: FriendRunningStatusViewState(
            id: 1,
            name: "민희",
            isMe: true,
            profileImageURL: nil,
            latestRanText: "1일 전",
            isRunning: true,
            distanceText: "5.01km",
            latitude: 37.4784,
            longitude: 126.8641
        ),
        city: "광명",
        isFocused: true,
        isSent: true
    )
}
