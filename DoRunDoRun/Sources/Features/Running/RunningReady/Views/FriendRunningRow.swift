//
//  FriendRunningRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/15/25.
//

import SwiftUI

struct FriendRunningRow: View {
    var name: String
    var time: String?
    var distance: String?
    var location: String?
    var isMine: Bool = false
    var isRunning: Bool = false
    var isSent: Bool = false
    var isFocus: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            profileImageView
            infoSection
            Spacer()
            cheerButton
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(isFocus ? Color(hex: 0xD2DCFF).opacity(0.25) : Color.gray0)
    }
}

// MARK: - Subviews
extension FriendRunningRow {

    /// 프로필 이미지
    @ViewBuilder
    private var profileImageView: some View {
        ProfileImageView(
            image: nil,
            style: isFocus ? .blueBorder : .grayBorder,
            isZZZ: !isRunning
        )
    }

    /// 정보 영역 (이름, 시간, 거리, 위치)
    @ViewBuilder
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .typography(.t2_700)

                if isMine {
                    Circle()
                        .fill(Color.blue600)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("나")
                                .typography(.c1_700, color: .gray0)
                        )
                }

                Spacer().frame(width: 12)

                if isRunning, let time {
                    Text(time)
                        .typography(.b2_500, color: .gray500)
                }
            }

            if isRunning, let distance, let location {
                HStack(spacing: 4) {
                    Text(distance)
                        .typography(.b2_500, color: .gray700)
                    Text("/")
                        .typography(.b2_500, color: .gray700)
                    Text(location)
                        .typography(.b2_500, color: .gray700)
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
        if !isRunning {
            AppButton(
                title: isSent ? "응원완료" : "응원하기",
                style: .primary,
                size: .small,
                isDisabled: isSent
            ) {
                // TODO: 응원 액션
            }
            .frame(width: 75)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        FriendRunningRow(
            name: "민희",
            time: "1시간 전",
            distance: "5.01km",
            location: "광명",
            isMine: true,
            isRunning: true,
            isSent: false,
            isFocus: true
        )

        FriendRunningRow(
            name: "해준",
            time: "30분 전",
            distance: "5.01km",
            location: "서울",
            isMine: false,
            isRunning: true,
            isSent: false,
            isFocus: false
        )

        FriendRunningRow(
            name: "수연",
            time: "10시간 전",
            distance: "5.01km",
            location: "서울",
            isMine: false,
            isRunning: true,
            isFocus: false
        )

        FriendRunningRow(
            name: "달리는하니",
            isMine: false,
            isRunning: false,
            isSent: false,
            isFocus: false
        )

        FriendRunningRow(
            name: "땡땡",
            isMine: false,
            isRunning: false,
            isSent: true,
            isFocus: false
        )
    }
}
