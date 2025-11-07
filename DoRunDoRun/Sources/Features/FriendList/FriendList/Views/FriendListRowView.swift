//
//  FriendListRowView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import SwiftUI

struct FriendListRowView: View {
    @State private var showMenu = false

    let friend: FriendRunningStatusViewState
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 12) {
                ProfileImageView(imageURL: friend.profileImageURL, style: .grayBorder, size: .large)
                VStack(alignment: .leading, spacing: 2) {
                    TypographyText(text: friend.name, style: .t2_700, color: .gray900)
                    if let latestRanText = friend.latestRanText {
                        TypographyText(text: latestRanText, style: .b2_400, color: .gray500)
                    }
                }
                Spacer()
                Button {
                    withAnimation { showMenu.toggle() }
                } label: {
                    Image(.more, size: .medium)
                        .renderingMode(.template)
                        .foregroundStyle(Color.gray500)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 76)

            if showMenu {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        showMenu = false
                        onDelete()
                    } label: {
                        TypographyText(text: "친구 삭제하기", style: .b2_400, color: .gray700)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                    }
                }
                .frame(width: 144)
                .background(Color.gray0)
                .cornerRadius(12)
                .shadow(color: Color.gray900.opacity(0.15), radius: 12, x: 0, y: 2)
                .offset(x: -20, y: 48)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

        }
        .onTapGesture {
            if showMenu { showMenu = false }
        }
    }
}
