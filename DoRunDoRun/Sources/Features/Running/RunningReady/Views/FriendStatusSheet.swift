//
//  FriendStatusSheet.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/15/25.
//

import SwiftUI

struct FriendStatusSheet: View {
    let friends: [Friend]
    @Binding var sheetOffset: CGFloat
    @Binding var currentOffset: CGFloat
    var sheetHeight: CGFloat = 400
    var collapsedOffset: CGFloat = 272 // 기본 내려간 상태 400 - 80(버튼 프레임 높이) - 48

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
        .onAppear {
            sheetOffset = collapsedOffset
            currentOffset = collapsedOffset
        }
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
                ForEach(friends) { friend in
                    FriendRunningRow(
                        name: friend.name,
                        time: friend.time,
                        distance: friend.distance,
                        location: friend.location,
                        isMine: friend.isMine,
                        isRunning: friend.isRunning,
                        isSent: friend.isSent,
                        isFocus: friend.isFocus
                    )
                }
            }
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
        friends: [
            Friend(name: "민희", time: "1시간 전", distance: "5.01km", location: "광명", isMine: true, isRunning: true, isSent: false, isFocus: true),
            Friend(name: "해준", time: "30분 전", distance: "5.01km", location: "서울", isMine: false, isRunning: true, isSent: false, isFocus: false),
            Friend(name: "수연", time: "10시간 전", distance: "5.01km", location: "서울", isMine: false, isRunning: true, isSent: false, isFocus: false),
            Friend(name: "달리는하니", time: nil, distance: nil, location: nil, isMine: false, isRunning: false, isSent: false, isFocus: false),
            Friend(name: "땡땡", time: nil, distance: nil, location: nil, isMine: false, isRunning: false, isSent: true, isFocus: false)
        ],
        sheetOffset: .constant(0),
        currentOffset: .constant(0)
    )
}
