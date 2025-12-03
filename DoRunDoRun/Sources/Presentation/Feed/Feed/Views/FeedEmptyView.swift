//
//  FeedEmptyView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI

struct FeedEmptyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(.empty1)
                .resizable()
                .frame(width: 120, height: 120)
            VStack(spacing: 0) {
                TypographyText(text: "정말 조용하네요..!", style: .t2_700)
                TypographyText(text: "지금 첫 러닝을 인증해보세요!", style: .b2_400, color: .gray700)
            }
            Spacer()
        }
        .padding(.top, -25)
        .padding(.bottom, 102)
    }
}
