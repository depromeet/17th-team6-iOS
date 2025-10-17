//
//  FriendRunningRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/15/25.
//

import SwiftUI

/// 친구의 러닝 상태를 표시하는 리스트 행(View)
///
/// 지도 하단 시트(FriendStatusSheet) 안에서 사용되며,
/// 각 친구의 이름, 러닝 상태, 거리/위치 정보, 응원 버튼 등을 표시합니다.
struct FriendRunningRow: View {
    let friend: Friend                  // 표시할 친구 데이터 모델
    let isFocus: Bool                   // 현재 포커스된(선택된) 친구인지 여부
    var onTap: (() -> Void)? = nil      // 행 탭 시 실행할 콜백

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
        .onTapGesture { onTap?() }
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
            isZZZ: !friend.isRunning
        )
    }

    /// 정보 영역 (이름, 시간, 거리, 위치)
    @ViewBuilder
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(friend.name)
                    .typography(.t2_700)

                if friend.isMine {
                    Circle()
                        .fill(Color.blue600)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("나")
                                .typography(.c1_700, color: .gray0)
                        )
                }

                Spacer().frame(width: 12)

                if friend.isRunning, let time = friend.time {
                    Text(time)
                        .typography(.b2_500, color: .gray500)
                }
            }

            if friend.isRunning, let distance = friend.distance, let location = friend.location {
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
        if !friend.isRunning {
            AppButton(
                title: friend.isSent ? "응원완료" : "응원하기",
                style: .primary,
                size: .small,
                isDisabled: friend.isSent
            ) {
                // TODO: 응원 액션
            }
            .frame(width: 75)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(RunningReadyFeature.mockFriends) { friend in
            FriendRunningRow(
                friend: friend,
                isFocus: friend.name == "민희" // 특정 친구만 포커스 테스트
            )
        }
    }
    .background(Color.gray50)
}

