//
//  UploadFeedView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import ComposableArchitecture
import SwiftUI

struct UploadFeedView: View {
    let store: StoreOf<UploadFeedFeature>

    var groupedRecords: [(Date, [RunningRecord])] {
        let grouped = Dictionary(grouping: store.runningRecords) { record in
            record.createdAt.startOfDay()
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("이전 러닝 내역")
                        .font(.pretendard(.bold, size: 22))
                        .foregroundStyle(Color.gray900)

                    Text("이틀 이내 달린 기록을 인증할 수 있어요.\n날짜별로 1회만 가능합니다.")
                        .font(.pretendard(.regular, size: 14))
                        .foregroundStyle(Color.gray600)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)

                if groupedRecords.isEmpty {
                    // 빈 상태 UI
                    VStack(spacing: 24) {
                        Spacer()

                        VStack(spacing: 24) {
                            // TODO: graphic_empty_2 이미지로 교체 필요
                            Image("ic_empty2")
                                .resizable()
                                .frame(width: 120, height: 120)

                            VStack(spacing: 4) {
                                Text("인증 가능한 기록이 없어요..")
                                    .font(.pretendard(.bold, size: 18))
                                    .foregroundStyle(Color.gray900)

                                Text("지금 바로 러닝을 시작해봐요!")
                                    .font(.pretendard(.regular, size: 14))
                                    .foregroundStyle(Color.gray700)
                            }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(groupedRecords, id: \.0) { date, records in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(date.toDateString())
                                        .font(.pretendard(.medium, size: 14))
                                        .foregroundStyle(Color.gray600)

                                    ForEach(records, id: \.runSessionID) { record in
                                        Button(action: {
                                            store.send(.selectRecord(record.runSessionID))
                                        }) {
                                            RunningRecordCard(
                                                record: record,
                                                isSelected: store.selectedRecordID == record.runSessionID
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }

                Spacer()

                VStack {
                    Button(action: {
                        store.send(.loadRecord)
                    }) {
                        Text("불러오기")
                            .font(.pretendard(.semiBold, size: 16))
                            .foregroundStyle(store.selectedRecordID != nil ? Color.white : Color.gray700)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(store.selectedRecordID != nil ? Color.blue600 : Color.gray200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(store.selectedRecordID == nil)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .background(Color.white)
            }
        }
        .onAppear {
            store.send(.fetchRunningRecords)
        }
    }
}

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

#Preview {
    UploadFeedView(store: .init(initialState: .init(), reducer: {
        UploadFeedFeature()
    }))
}
