//
//  FeedRunningRecordCard.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//

import ComposableArchitecture
import SwiftUI

struct FeedRunningRecordCard: View {
    let mapImageURL: URL?
    let createdAt: Date
    let distance: String
    let duration: String
    let pace: String
    let cadence: String
    let showDateTime: Bool
    let customBackgroundImage: UIImage?

    init(
        mapImageURL: URL?,
        createdAt: Date,
        distance: String,
        duration: String,
        pace: String,
        cadence: String,
        showDateTime: Bool = true,
        customBackgroundImage: UIImage? = nil
    ) {
        self.mapImageURL = mapImageURL
        self.createdAt = createdAt
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.cadence = cadence
        self.showDateTime = showDateTime
        self.customBackgroundImage = customBackgroundImage
    }

    // RunningRecord로부터 초기화하는 편의 생성자
    init(record: RunningRecord, showDateTime: Bool = true, customBackgroundImage: UIImage? = nil) {
        self.mapImageURL = record.mapImageURL
        self.createdAt = record.createdAt
        self.distance = record.distanceTotal.formatDistance()
        self.duration = record.durationTotal.formatTime()
        self.pace = record.paceAvg.formatPace()
        self.cadence = "\(record.cadanceAvg) spm"
        self.showDateTime = showDateTime
        self.customBackgroundImage = customBackgroundImage
    }

    var body: some View {
        GeometryReader { geometry in
            WithPerceptionTracking {
                ZStack(alignment: .topLeading) {
                // 배경 이미지 (커스텀 이미지 우선, 없으면 지도 이미지)
                if let customImage = customBackgroundImage {
                    Image(uiImage: customImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if let mapImageURL = mapImageURL {
                    AsyncImage(url: mapImageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray300
                    }
                } else {
                    Color.gray300
                }

                VStack(alignment: .leading, spacing: 0) {
                    // 날짜/시간 칩
                    if showDateTime {
                        HStack(spacing: 4) {
                            Text(createdAt.toDateString())

                            Text("·")

                            Text(createdAt.toTimeString())
                        }
                        .font(.pretendard(.regular, size: 12))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                        .padding(20)
                    }

                    Spacer()

                    // 하단 통계 정보 with 그라데이션 오버레이
                    VStack(spacing: 12) {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("달린 거리")
                                    .font(.pretendard(.regular, size: 12))
                                Text(distance)
                                    .font(.pretendard(.bold, size: 28))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 0) {
                                Text("달린 시간")
                                    .font(.pretendard(.regular, size: 12))
                                Text(duration)
                                    .font(.pretendard(.bold, size: 28))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("평균 페이스")
                                    .font(.pretendard(.regular, size: 12))
                                Text(pace)
                                    .font(.pretendard(.bold, size: 20))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 0) {
                                Text("평균 케이던스")
                                    .font(.pretendard(.regular, size: 12))
                                Text(cadence)
                                    .font(.pretendard(.bold, size: 20))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .foregroundStyle(Color.white)
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0),
                                Color.black.opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    FeedRunningRecordCard(
        mapImageURL: nil,
        createdAt: Date(),
        distance: "8.02km",
        duration: "1:52:06",
        pace: "7'30''",
        cadence: "144 spm"
    )
    .padding(20)
}
