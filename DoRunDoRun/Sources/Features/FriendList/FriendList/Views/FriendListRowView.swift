//
//  FriendListRowView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import SwiftUI

struct FriendListRowView: View {
    let friend: FriendRunningStatusViewState
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProfileImageView(
                image: Image(.profilePlaceholder),
                imageURL: friend.profileImageURL,
                style: .grayBorder,
                size: .large
            )
            
            VStack(alignment: .leading, spacing: 2) {
                TypographyText(text: friend.name, style: .t2_700, color: .gray900)
                if let latestRanText = friend.latestRanText {
                    TypographyText(text: latestRanText, style: .b2_400, color: .gray500)
                }
            }
            
            Spacer()
            
            Menu {
                Button("친구 삭제하기") {
                    onDelete()
                }
            } label: {
                Image(.more, size: .medium)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray500)
            }
            .menuStyle(.button)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .padding(.horizontal, 20)
        .frame(height: 76)
    }
}
