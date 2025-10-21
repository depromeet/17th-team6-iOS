//
//  FriendRunningStatusSheet.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

/// 유저 및 친구 러닝 상태를 표시하는 하단 시트(View)
struct FriendRunningStatusSheet: View {
    let statuses: [FriendRunningStatusViewState]
    let cityCache: [Int: String]
    let focusedFriendID: Int?
    let sentReactions: Set<Int>
    
    @Binding var sheetOffset: CGFloat
    @Binding var currentOffset: CGFloat
    
    var sheetHeight: CGFloat = 400
    var collapsedOffset: CGFloat = 272
    
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
private extension FriendRunningStatusSheet {
    var handleBar: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 32, height: 5)
                .foregroundStyle(Color.gray100)
        }
        .frame(height: 24)
    }

    var header: some View {
        HStack {
            TypographyText(text: "친구 두런 현황", style: .t1_700)
            Spacer()
            Button {
                friendListButtonTapped?()
            } label: {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(Color.gray800)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
    }

    var friendList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(statuses) { status in
                    FriendRunningStatusRow(
                        status: status,
                        city: cityCache[status.id] ?? "알 수 없음",
                        isFocused: status.id == focusedFriendID,
                        isSent: sentReactions.contains(status.id),
                        friendTapped: { friendTapped?(status.id) },
                        cheerButtonTapped: { cheerButtonTapped?(status.id) }
                    )
                }

            }
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Gesture
private extension FriendRunningStatusSheet {
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
    FriendRunningStatusSheet(
        statuses: [
            .init(
                id: 1,
                name: "민희",
                isMe: true,
                profileImageURL: nil,
                latestRanText: "1시간 전",
                isRunning: true,
                distanceText: "5.01km",
                latitude: 37.4784,
                longitude: 126.8641
            ),
            .init(
                id: 2,
                name: "해준",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "30분 전",
                isRunning: true,
                distanceText: "5.01km",
                latitude: 37.5665,
                longitude: 126.9780
            ),
            .init(
                id: 3,
                name: "수연",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "10시간 전",
                isRunning: true,
                distanceText: "5.01km",
                latitude: 37.5700,
                longitude: 126.9820
            ),
            .init(
                id: 4,
                name: "달리는하니",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "3일 전",
                isRunning: false,
                distanceText: nil,
                latitude: nil,
                longitude: nil
            ),
            .init(
                id: 5,
                name: "땡땡",
                isMe: false,
                profileImageURL: nil,
                latestRanText: "12일 전",
                isRunning: false,
                distanceText: nil,
                latitude: nil,
                longitude: nil
            ),
        ],
        cityCache: [
            1 : "광명",
            2 : "서울",
            3 : "서울"
        ],
        focusedFriendID: 1,
        sentReactions: [],
        sheetOffset: .constant(0),
        currentOffset: .constant(0)
    )
}
