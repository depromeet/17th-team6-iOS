//
//  EditFeedImageView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//

import ComposableArchitecture
import PhotosUI
import SwiftUI

struct EditFeedImageView: View {
    let store: StoreOf<EditFeedImageFeature>
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // 상단 네비게이션 바
                HStack {
                    // 뒤로가기 버튼
                    Button(action: {
                        store.send(.backButtonTapped)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.gray900)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    // 다운로드 버튼
                    Button(action: {
                        store.send(.downloadButtonTapped)
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.gray900)
                            .frame(width: 44, height: 44)
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)

                // 러닝 기록 카드와 버튼들
                VStack(spacing: 12) {
                    FeedRunningRecordCard(
                        record: store.runningRecord,
                        showDateTime: true,
                        customBackgroundImage: store.backgroundImage
                    )
                    .frame(width: 335, height: 335)

                    // 배경사진 변경 버튼
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Text("배경사진 변경")
                            .font(.pretendard(.bold, size: 16))
                            .foregroundStyle(Color.blue600)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blue200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .frame(width: 335)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data)
                            {
                                store.send(.backgroundImageSelected(image))
                            }
                        }
                    }
                }
                .padding(.top, 40)

                Spacer()

                // 게시물 올리기 버튼
                Button(action: {
                    store.send(.postButtonTapped)
                }) {
                    Text("게시물 올리기")
                        .font(.pretendard(.bold, size: 16))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue600)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .background(Color.white)
        }
    }
}

#Preview {
    EditFeedImageView(
        store: .init(
            initialState: .init(
                runningRecord: RunningRecord(
                    runSessionID: 1,
                    createdAt: Date(),
                    distanceTotal: 8020,
                    durationTotal: 6726,
                    paceAvg: 450,
                    cadanceAvg: 144,
                    isSelfied: true,
                    mapImageURL: nil
                )
            ),
            reducer: {
                EditFeedImageFeature()
            }
        )
    )
}
