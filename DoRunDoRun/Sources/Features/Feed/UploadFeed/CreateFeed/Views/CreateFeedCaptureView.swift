//
//  CreateFeedCaptureView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import SwiftUI
import Kingfisher

struct CreateFeedCaptureView: View {
    let session: RunningSessionSummaryViewState
    let selectedImage: UIImage?

    var body: some View {
        ZStack(alignment: .bottom) {
            // 피드 이미지
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .clipped()
            } else if let urlString = session.mapImageURL,
                      let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray100)
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .cornerRadius(16)
            }

            // 달리기 정보 오버레이
            runningInfoOverlay
        }
        .cornerRadius(16)
        .clipped()
    }

    // MARK: - 달리기 정보 오버레이
    var runningInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                TypographyText(text: session.dateText, style: .c1_400, color: .gray0)
                TypographyText(text: "·", style: .c1_400, color: .gray0)
                TypographyText(text: session.timeText, style: .c1_400, color: .gray0)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.dimLight)
            .clipShape(.capsule)
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                HStack {
                    metricRow(title: "달린 거리", value: session.distanceText)
                    metricRow(title: "달린 시간", value: session.durationText)
                }
                HStack {
                    metricRow(title: "평균 페이스", value: session.paceText)
                    metricRow(title: "평균 케이던스", value: session.spmText)
                }
            }
            .padding(.top, 80)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: 0x000000, alpha: 0.8),
                        Color(hex: 0x000000, alpha: 0.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    }

    // MARK: - 메트릭 행
    func metricRow(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                TypographyText(text: title, style: .c1_400, color: .gray0)
                TypographyText(text: value, style: .h1_700, color: .gray0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
