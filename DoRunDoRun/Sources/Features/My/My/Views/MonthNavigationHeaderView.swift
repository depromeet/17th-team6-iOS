//
//  MonthNavigationHeaderView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI

struct MonthNavigationHeaderView: View {
    let monthTitle: String
    let onPreviousTapped: () -> Void
    let onNextTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 이전 달로 이동 버튼
            Button(action: onPreviousTapped) {
                Image(.arrowLeft, size: .small)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray300)
            }
            
            // 현재 월 텍스트 (예: "2025년 11월")
            Text(monthTitle)
                .font(.subheadline.bold())
                .foregroundColor(.gray900)

            // 다음 달로 이동 버튼
            Button(action: onNextTapped) {
                Image(.arrowRight, size: .small)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray300)
            }
        }
        .frame(height: 44)
        .padding(.vertical, 4)
    }
}

