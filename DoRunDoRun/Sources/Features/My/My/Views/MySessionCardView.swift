//
//  MySessionCardView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import SwiftUI

struct MySessionCardView: View {
    let session: RunningSessionSummaryViewState
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // MARK: - 상단 시간 + 태그
                    HStack {
                        TypographyText(text: session.timeText, style: .b2_500, color: .gray700)

                        switch session.tagStatus {
                        case .possible:
                            TagLabel(status: .possible)
                        case .completed:
                            TagLabel(status: .completed)
                        case .none:
                            EmptyView()
                        }

                        Spacer()
                    }

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

                if session.tagStatus == .completed {
                    Image(.runningVerified)
                        .resizable()
                        .frame(width: 72, height: 72)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray100, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TagLabel: View {
    let status: CertificationStatus

    private var text: String {
        switch status {
        case .completed: return "인증 완료"
        case .possible: return "인증 가능"
        case .none: return ""
        }
    }
    
    private var textColor: Color {
        switch status {
        case .possible: return Color.blue600
        case .completed: return Color.gray0
        case .none: return Color.clear
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .completed: return Color.blue600
        case .possible: return Color.blue100
        case .none: return Color.clear
        }
    }

    var body: some View {
        if status != .none {
            TypographyText(
                text: text,
                style: .c1_500,
                color: textColor
            )
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(backgroundColor)
            .cornerRadius(13)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MySessionCardView(session: RunningSessionSummaryViewState(
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
        ))

        MySessionCardView(session: RunningSessionSummaryViewState(
            id: 2,
            date: Date(),
            dateText: "2025.09.29 (월)",
            timeText: "오전 08:32",
            distanceText: "5.10km",
            durationText: "00:45:10",
            paceText: "7'10\"",
            spmText: "130 spm",
            tagStatus: .possible,
            mapImageURL: nil
        ))

        MySessionCardView(session: RunningSessionSummaryViewState(
            id: 3,
            date: Date(),
            dateText: "2025.09.28 (일)",
            timeText: "오전 07:05",
            distanceText: "3.00km",
            durationText: "00:20:00",
            paceText: "6'40\"",
            spmText: "125 spm",
            tagStatus: .none,
            mapImageURL: nil
        ))
    }
    .padding(.horizontal, 20)
    .background(Color.gray50)
}
