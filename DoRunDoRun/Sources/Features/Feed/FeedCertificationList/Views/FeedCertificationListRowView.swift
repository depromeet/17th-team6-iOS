//
//  FeedCertificationListRowView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI

struct FeedCertificationListRowView: View {
    let user: SelfieUserViewState
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProfileImageView(
                image: Image(.profilePlaceholder),
                imageURL: user.profileImageUrl,
                style: .grayBorder,
                size: .large
            )
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    TypographyText(text: user.name, style: .t2_700, color: .gray900)
                    if user.isMe {
                        Circle()
                            .fill(Color.blue600)
                            .frame(width: 20, height: 20)
                            .overlay(Text("나").typography(.c1_700, color: .gray0))
                    }
                }
                TypographyText(text: user.postingTime, style: .b2_400, color: .gray500)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 76)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
