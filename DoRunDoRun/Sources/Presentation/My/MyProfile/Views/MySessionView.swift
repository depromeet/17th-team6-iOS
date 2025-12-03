//
//  MySessionView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI

struct MySessionView: View {
    let sessions: [RunningSessionSummaryViewState]
    var onSessionTap: ((RunningSessionSummaryViewState) -> Void)? = nil

    var body: some View {
        ScrollView {
            sessionListSection
        }
    }
}

// MARK: - Subviews
private extension MySessionView {
    /// 세션 목록 섹션
    var sessionListSection: some View {
        LazyVStack(alignment: .leading, spacing: 36) {
            ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { dateText in
                dateGroupSection(for: dateText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    /// 날짜별 그룹 섹션
    func dateGroupSection(for dateText: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TypographyText(text: dateText, style: .b2_500, color: .gray500)

            ForEach(groupedSessions[dateText] ?? []) { session in
                MySessionCardView(session: session) {
                    onSessionTap?(session)
                }
            }
        }
    }
}

// MARK: - Helpers
private extension MySessionView {
    /// 날짜별 그룹화 (String 기반)
    var groupedSessions: [String: [RunningSessionSummaryViewState]] {
        Dictionary(grouping: sessions, by: { $0.dateText })
    }
}
