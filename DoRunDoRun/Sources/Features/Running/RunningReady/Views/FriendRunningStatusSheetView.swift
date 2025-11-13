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
    var cheerButtonTapped: ((Int, String) -> Void)? = nil
    var loadNextPageIfNeeded: ((FriendRunningStatusViewState?) -> Void)? = nil
    var isLoading: Bool = false

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
        // friends를 ViewBuilder 바깥에서 선언
        let friends = statuses.filter { !$0.isMe }

        return ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // 항상 '나'를 먼저 표시
                if let me = statuses.first(where: { $0.isMe }) {
                    FriendRunningStatusRowView(
                        status: me,
                        isFocused: me.id == focusedFriendID,
                        friendTapped: { friendTapped?(me.id) },
                        cheerButtonTapped: { cheerButtonTapped?(me.id, me.name) }
                    )
                }

                // 친구 목록
                if friends.isEmpty {
                    FriendRunningStatusEmptyView()
                        .padding(.top, 80)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(friends, id: \.renderId) { status in
                        FriendRunningStatusRowView(
                            status: status,
                            isFocused: status.id == focusedFriendID,
                            friendTapped: { friendTapped?(status.id) },
                            cheerButtonTapped: { cheerButtonTapped?(status.id, status.name) }
                        )
                        // 마지막 셀 감지 (페이지네이션)
                        .onAppear {
                            if status.id == friends.last?.id {
                                loadNextPageIfNeeded?(status)
                            }
                        }
                    }
                    // 로딩 인디케이터
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
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
