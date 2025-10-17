//
//  FriendStatusSheet.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/15/25.
//

import SwiftUI

/// 친구들의 러닝 현황을 표시하는 하단 시트(View)
///
/// `RunningReadyView`의 하단에 위치하며,
/// 친구들의 러닝 상태, 거리, 위치를 리스트 형태로 표시합니다.
/// 드래그 제스처를 통해 시트를 위·아래로 이동할 수 있습니다.
struct FriendStatusSheet: View {
    let friends: [Friend]                       // 표시할 친구 목록
    let focusedFriendID: UUID?                  // 현재 포커싱된 친구 ID
    @Binding var sheetOffset: CGFloat           // 시트의 현재 오프셋 (드래그 중 상태)
    @Binding var currentOffset: CGFloat         // 드래그 종료 시 기준 오프셋
    var sheetHeight: CGFloat = 400              // 전체 시트 높이 (기본값 400)
    var collapsedOffset: CGFloat = 272          // 기본 내려간 상태의 오프셋 (400 - 버튼 높이 80 - 여백 48)
    var onFriendTap: ((UUID) -> Void)? = nil    // 친구 셀 탭 시 호출되는 콜백

    var body: some View {
        VStack(spacing: 0) {
            handleBar
            header
            friendList
        }
        .frame(height: sheetHeight)
        .frame(maxWidth: .infinity)
        .background(Color.gray0)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .offset(y: sheetOffset)
        .gesture(dragGesture)
    }
}

// MARK: - Subviews
extension FriendStatusSheet {
    /// 상단 핸들바
    @ViewBuilder
    private var handleBar: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 32, height: 5)
                .foregroundStyle(Color.gray100)
        }
        .frame(height: 24)
    }

    /// 헤더
    @ViewBuilder
    private var header: some View {
        HStack {
            Text("친구 두런 현황")
                .typography(.t1_700)
            Spacer()
            Button {
                // TODO: 친구 목록으로 이동 액션
            } label: {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(Color.gray800)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
    }

    /// 친구 리스트
    @ViewBuilder
    private var friendList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(friends, id: \.id) { friend in
                    FriendRunningRow(
                        friend: friend,
                        isFocus: friend.id == focusedFriendID
                    ) {
                        onFriendTap?(friend.id)
                    }
                }
            }
            .padding(.bottom, 80) // 버튼 공간 확보
        }
    }
}

// MARK: - Gesture
extension FriendStatusSheet {
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                sheetOffset = max(0, currentOffset + value.translation.height)
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    if value.translation.height > 150 {
                        sheetOffset = collapsedOffset
                    } else {
                        sheetOffset = 0
                    }
                    currentOffset = sheetOffset
                }
            }
    }
}

// MARK: - Preview
#Preview {
    FriendStatusSheet(
        friends: RunningReadyFeature.mockFriends,
        focusedFriendID: RunningReadyFeature.mockFriends.first!.id,
        sheetOffset: .constant(0),
        currentOffset: .constant(0)
    )
}
