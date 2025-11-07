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
            Button(action: onPreviousTapped) {
                Image(.arrowLeft, size: .small)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray300)
            }
            
            Text(monthTitle)
                .font(.subheadline.bold())
                .foregroundColor(.gray900)

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

