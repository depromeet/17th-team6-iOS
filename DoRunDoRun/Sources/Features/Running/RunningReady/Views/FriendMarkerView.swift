//
//  FriendMarkerView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/16/25.
//

import SwiftUI

/// 지도 위에 표시되는 친구 마커(View)
///
/// 닉네임, 말풍선 이미지, 프로필 이미지로 구성된 마커입니다.
/// `isFocus`가 `true`일 때는 포커스 테두리가 적용되고,
/// `isRunning`이 `false`일 경우 ZZZ 상태(휴식 상태) 표시가 적용됩니다.
struct FriendMarkerView: View {
    let profileImage: Image?    // 표시할 프로필 이미지 (없으면 기본 이미지 사용)
    let name: String            // 친구 닉네임
    let isRunning: Bool         // 러닝 중인지 여부
    let isFocus: Bool           // 현재 포커싱된 친구인지 여부

    var body: some View {
        VStack(spacing: 8) {
            nicknameLabel
            markerBubble
        }
    }
}

// MARK: - Subviews
private extension FriendMarkerView {
    /// 닉네임 텍스트 영역
    @ViewBuilder
    var nicknameLabel: some View {
        Text(name)
            .typography(.c1_700, color: .gray900)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.gray0)
            .cornerRadius(8)
    }

    /// 말풍선과 프로필 이미지를 겹쳐 표시하는 영역
    @ViewBuilder
    var markerBubble: some View {
        ZStack {
            // 말풍선 베이스 이미지
            Image("graphic_friend_marker")
                .renderingMode(.original)

            // 프로필 이미지 (포커스 및 러닝 상태 반영)
            ProfileImageView(
                image: profileImage,
                style: isFocus ? .blueBorder : .grayBorder,
                isZZZ: !isRunning
            )
            .offset(y: -4) // 살짝 아래로 내려서 중앙 정렬 보정
        }
    }
}

// MARK: - Preview
#Preview {
    FriendMarkerView(
        profileImage: nil,
        name: "민희",
        isRunning: true,
        isFocus: true
    )
    .background(Color.gray100)
}
