//
//  MyFeedMonthHeaderView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI

struct MyFeedMonthHeaderView: View {
    let year: String
    let month: String

    var body: some View {
        VStack(spacing: 0) {
            // 현재 년도 텍스트 (예: "2025")
            TypographyText(text: year, style: .b2_400, color: .gray600)
            // 현재 월 텍스트 (예: "11월")
            TypographyText(text: month, style: .h1_500, color: .gray900)
        }
    }
}
