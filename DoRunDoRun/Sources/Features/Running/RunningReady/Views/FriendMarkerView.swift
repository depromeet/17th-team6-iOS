//
//  FriendMarkerView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

/// 지도 위에 표시되는 유저 및 친구 마커(View)
struct FriendMarkerView: View {
    let name: String
    let profileImage: Image?
    let isRunning: Bool
    let isFocused: Bool

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
                style: isFocused ? .blueBorder : .grayBorder,
                isZZZ: !isRunning
            )
            .offset(y: -4) // 살짝 아래로 내려서 중앙 정렬 보정
        }
    }
}

// MARK: - Preview
#Preview {
    FriendMarkerView(
        name: "민희",
        profileImage: nil,
        isRunning: true,
        isFocused: true
    )
}
