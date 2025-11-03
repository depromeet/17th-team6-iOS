//
//  FriendRunningStatusSheetView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

/// 유저 및 친구 러닝 상태를 표시하는 하단 시트(View)
struct FriendRunningStatusSheetView: View {
    let statuses: [FriendRunningStatusViewState]
    let focusedFriendID: Int?
    
    @Binding var sheetOffset: CGFloat
    @Binding var currentOffset: CGFloat
    
    var sheetHeight: CGFloat = 446
    var collapsedOffset: CGFloat = 289
    
    var friendListButtonTapped: (() -> Void)? = nil
    var friendTapped: ((Int) -> Void)? = nil
    var cheerButtonTapped: ((Int) -> Void)? = nil

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
private extension FriendRunningStatusSheetView {
    var handleBar: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 32, height: 5)
                .foregroundStyle(Color.gray100)
                .padding(.vertical, 16)
        }
    }

    var header: some View {
        HStack {
            TypographyText(text: "친구 현황", style: .t1_700)
            Spacer()
            Button {
                friendListButtonTapped?()
            } label: {
                Image(.friends, fill: .fill, size: .medium)
                    .foregroundStyle(Color.gray800)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
    }

    var friendList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 항상 '나'를 먼저 표시
                if let me = statuses.first(where: { $0.isMe }) {
                    FriendRunningStatusRowView(
                        status: me,
                        isFocused: me.id == focusedFriendID,
                        friendTapped: { friendTapped?(me.id) },
                        cheerButtonTapped: { cheerButtonTapped?(me.id) }
                    )
                }

                // 친구 목록
                let friends = statuses.filter { !$0.isMe }
                if friends.isEmpty {
                    FriendRunningStatusEmptyView()
                        .padding(.top, 80)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(friends) { status in
                        FriendRunningStatusRowView(
                            status: status,
                            isFocused: status.id == focusedFriendID,
                            friendTapped: { friendTapped?(status.id) },
                            cheerButtonTapped: { cheerButtonTapped?(status.id) }
                        )
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 76)
        }
    }
}

// MARK: - Gesture
private extension FriendRunningStatusSheetView {
    var dragGesture: some Gesture {
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
    FriendRunningStatusSheetView(
        statuses: [
            .init(
                id: 1,
                name: "민희",
                isMe: true,
                profileImageURL: nil,
                latestRanText: "1시간 전",
                latestCheeredAt: nil,
                isRunning: true,
                isCheerable: false,
                distanceText: "5.01km",
                latitude: 37.4784,
                longitude: 126.8641,
                address: "경기"
            ),
            .init(
                id: 2,
                name: "해준",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "30분 전",
                latestCheeredAt: nil,
                isRunning: true,
                isCheerable: false,
                distanceText: "5.01km",
                latitude: 37.5665,
                longitude: 126.9780,
                address: "서울"
            ),
            .init(
                id: 3,
                name: "수연",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "10시간 전",
                latestCheeredAt: nil,
                isRunning: true,
                isCheerable: false,
                distanceText: "5.01km",
                latitude: 37.5700,
                longitude: 126.9820,
                address: "서울"
            ),
            .init(
                id: 4,
                name: "달리는하니",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "3일 전",
                latestCheeredAt: Calendar.current.date(byAdding: .day, value: -2, to: .now), // 응원한지 이틀 경과
                isRunning: false,
                isCheerable: true, // 응원한지 이틀 경과했기에 깨우기 가능
                distanceText: nil,
                latitude: nil,
                longitude: nil,
                address: nil
            ),
            .init(
                id: 5,
                name: "땡땡",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "12일 전",
                latestCheeredAt: Calendar.current.date(byAdding: .day, value: -2, to: .now), // 응원한지 이틀 경과
                isRunning: false,
                isCheerable: true,  // 응원한지 이틀 경과했기에 깨우기 가능
                distanceText: nil,
                latitude: nil,
                longitude: nil,
                address: nil
            ),
        ],
        focusedFriendID: 1,
        sheetOffset: .constant(0),
        currentOffset: .constant(0)
    )
}
