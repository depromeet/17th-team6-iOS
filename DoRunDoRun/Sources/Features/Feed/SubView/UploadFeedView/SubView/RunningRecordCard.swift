
//
//  RunningRecordCard.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//


import ComposableArchitecture
import SwiftUI

struct RunningRecordCard: View {
    let record: RunningRecord
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.createdAt.toTimeString())
                .font(.pretendard(.medium, size: 12))
                .foregroundStyle(Color.gray700)

            Text(record.distanceTotal.formatDistance())
                .font(.pretendard(.bold, size: 28))
                .foregroundStyle(Color.gray900)

            HStack(spacing: 12) {
                Text(record.durationTotal.formatTime())
                    .font(.pretendard(.medium, size: 14))
                    .foregroundStyle(Color.gray700)

                Divider()

                Text(record.paceAvg.formatPace())
                    .font(.pretendard(.medium, size: 14))
                    .foregroundStyle(Color.gray700)

                Divider()

                Text("\(record.cadanceAvg) spm")
                    .font(.pretendard(.medium, size: 14))
                    .foregroundStyle(Color.gray700)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue600 : Color.gray200, lineWidth: 1)
        )
    }
}
