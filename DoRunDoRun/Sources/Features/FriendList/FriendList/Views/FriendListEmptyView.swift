//
//  FriendListEmptyView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import SwiftUI

struct FriendListEmptyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Rectangle()
                .foregroundStyle(Color.gray100)
                .frame(width: 100, height: 100)
            VStack(spacing: 4) {
                TypographyText(text: "아직 친구가 없어요", style: .t2_700, color: .gray900)
                TypographyText(text: "친구코드로 친구를 추가해주세요.", style: .b2_400, color: .gray700)
            }
        }
    }
}

#Preview {
    FriendListEmptyView()
}
