//
//  MySessionView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI

struct MySessionView: View {
    let sessions: [RunningSessionSummaryViewState]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 36) {
                // 날짜별 그룹화된 key (dateText 기준)
                ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { dateText in
                    VStack(alignment: .leading, spacing: 12) {
                        TypographyText(text: dateText, style: .b2_500, color: .gray500)
                        ForEach(groupedSessions[dateText] ?? []) { session in
                            MySessionCardView(session: session)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    // 날짜별 그룹화 (String 기반)
    private var groupedSessions: [String: [RunningSessionSummaryViewState]] {
        Dictionary(grouping: sessions, by: { $0.dateText })
    }
}

#Preview {
    MySessionView(sessions: [
        RunningSessionSummaryViewState(
            id: 1,
            date: Date(),
            dateText: "2025.09.30 (화)",
            timeText: "오전 10:11",
            distanceText: "8.02km",
            durationText: "01:12:03",
            paceText: "6'45\"",
            spmText: "128 spm",
            tagStatus: .completed,
            mapImageURL: nil
        ),
        RunningSessionSummaryViewState(
            id: 2,
            date: Date(),
            dateText: "2025.09.30 (화)",
            timeText: "오전 09:30",
            distanceText: "5.10km",
            durationText: "00:45:10",
            paceText: "7'10\"",
            spmText: "130 spm",
            tagStatus: .possible,
            mapImageURL: nil
        ),
        RunningSessionSummaryViewState(
            id: 3,
            date: Date(),
            dateText: "2025.09.29 (월)",
            timeText: "오전 07:05",
            distanceText: "3.00km",
            durationText: "00:20:00",
            paceText: "6'40\"",
            spmText: "125 spm",
            tagStatus: .none,
            mapImageURL: nil
        )
    ])
}

