//
//  FriendRunningStatusEmptyView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/29/25.
//

import SwiftUI

struct FriendRunningStatusEmptyView: View {
    var body: some View {
        VStack(spacing: 4) {
            TypographyText(
                text: "친구가 없어요..",
                style: .t2_700,
                color: .gray900
            )
            TypographyText(
                text: "친구를 초대해 함께 달려보세요!",
                style: .b2_400,
                color: .gray700
            )
        }
    }
}

#Preview {
    FriendRunningStatusEmptyView()
}
