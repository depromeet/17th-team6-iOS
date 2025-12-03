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
        Button { onTap?() } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    headerSection
                    distanceSection
                    detailSection
                }
                Spacer()
                verifiedImageSection
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.gray100, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews
private extension MySessionCardView {
    /// 상단 시간 + 태그 섹션
    var headerSection: some View {
        HStack {
            TypographyText(text: session.timeText, style: .b2_500, color: .gray700)
            switch session.tagStatus {
            case .possible: TagLabel(status: .possible)
            case .completed: TagLabel(status: .completed)
            case .none: EmptyView()
            }
            Spacer()
        }
    }

    /// 거리 섹션
    var distanceSection: some View {
        TypographyText(text: session.distanceText, style: .h2_700, color: .gray900)
    }

    /// 하단 상세 정보 섹션
    var detailSection: some View {
        HStack(spacing: 8) {
            infoText(session.durationText)
            divider
            infoText(session.paceText)
            divider
            infoText(session.spmText)
        }
    }

    /// 인증 완료 이미지 섹션
    @ViewBuilder
    var verifiedImageSection: some View {
        if session.tagStatus == .completed {
            Image(.runningVerified)
                .resizable()
                .frame(width: 72, height: 72)
        }
    }
}

// MARK: - Helper Views
private extension MySessionCardView {
    func infoText(_ text: String) -> some View {
        TypographyText(text: text, style: .b1_400, color: .gray700)
    }

    var divider: some View {
        Rectangle()
            .frame(width: 1, height: 14)
            .foregroundStyle(Color.gray100)
    }
}
