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
            TypographyText(text: year, style: .b2_400, color: .gray600)
            TypographyText(text: month, style: .h1_500, color: .gray900)
        }
    }
}
