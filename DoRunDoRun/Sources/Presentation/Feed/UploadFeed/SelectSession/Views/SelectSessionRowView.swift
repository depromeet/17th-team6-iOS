//
//  SelectSessionRowView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import SwiftUI

struct SelectSessionRowView: View {
    let session: RunningSessionSummaryViewState
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // MARK: - 상단 시간
                TypographyText(text: session.timeText, style: .b2_500, color: .gray700)

                // MARK: - 거리
                TypographyText(
                    text: session.distanceText,
                    style: .h2_700,
                    color: .gray900
                )

                // MARK: - 하단 상세 정보
                HStack(spacing: 8) {
                    TypographyText(
                        text: session.durationText,
                        style: .b1_400,
                        color: .gray700
                    )
                    Rectangle()
                        .frame(width: 1, height: 14)
                        .foregroundStyle(Color.gray100)
                    TypographyText(
                        text: session.paceText,
                        style: .b1_400,
                        color: .gray700
                    )
                    Rectangle()
                        .frame(width: 1, height: 14)
                        .foregroundStyle(Color.gray100)
                    TypographyText(
                        text: session.spmText,
                        style: .b1_400,
                        color: .gray700
                    )
                }
            }
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isSelected ? Color.blue600 : Color.gray100,
                    lineWidth: 1
                )
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
