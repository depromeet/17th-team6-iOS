//
//  MyFeedView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI

struct MyFeedView: View {
    let feeds: [SelfieFeedViewState]
    var loadNextPageIfNeeded: ((SelfieFeedViewState?) -> Void)? = nil
    var isLoading: Bool = false
    var onFeedTap: ((SelfieFeedItem) -> Void)? = nil
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(feeds, id: \.id) { feed in
                    switch feed.kind {
                    case let .monthHeader(year, month):
                        MyFeedMonthHeaderView(year: year, month: month)
                            .gridCellColumns(3)
                    case let .feed(item):
                        MyFeedItemView(item: item) {
                            onFeedTap?(item)
                        }
                        .onAppear {
                            // feed 타입 셀만 추출
                            let dataCells = feeds.filter {
                                if case .feed = $0.kind { return true }
                                return false
                            }
                            
                            // 현재 셀이 feed이고 마지막 데이터 셀일 때만 트리거
                            if case .feed = feed.kind,
                               let lastDataCell = dataCells.last,
                               feed.id == lastDataCell.id {
                                loadNextPageIfNeeded?(feed)
                            }
                        }

                    }
                }
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
    }
}

// MARK: - Preview
#Preview {
    let feeds: [SelfieFeedViewState] = [
        .init(
            id: "header-2025-10",
            kind: .monthHeader(year: "2025", month: "10월")
        ),
        .init(
            id: "feed-1",
            kind: .feed(
                .init(
                    feedID: 1,
                    dayText: "14일",
                    imageURL: "https://picsum.photos/200",
                    isMap: false,
                    userName: "두런두런",
                    profileImageURL: "https://picsum.photos/60",
                    totalDistanceText: "8.02km",
                    totalRunTimeText: "1:52:06",
                    averagePaceText: "7'30\"",
                    cadence: 144,
                    reactions: [
                        ReactionViewState(emojiType: .heart, totalCount: 2, isReactedByMe: false, users: []),
                        ReactionViewState(emojiType: .fire, totalCount: 1, isReactedByMe: true, users: [])
                    ],
                    dateText: "2025.10.15",
                    timeText: "오후 1:25"
                )
            )
        ),
        .init(
            id: "feed-2",
            kind: .feed(
                .init(
                    feedID: 2,
                    dayText: "12일",
                    imageURL: "https://picsum.photos/201",
                    isMap: false,
                    userName: "하늘",
                    profileImageURL: "https://picsum.photos/61",
                    totalDistanceText: "5.12km",
                    totalRunTimeText: "0:48:03",
                    averagePaceText: "6'45\"",
                    cadence: 130,
                    reactions: [
                        ReactionViewState(emojiType: .thumbsUp, totalCount: 3, isReactedByMe: false, users: [])
                    ],
                    dateText: "2025.10.15",
                    timeText: "오후 1:25"
                )
            )
        ),
        .init(
            id: "feed-3",
            kind: .feed(
                .init(
                    feedID: 3,
                    dayText: "09일",
                    imageURL: nil,
                    isMap: true,
                    userName: "민희",
                    profileImageURL: "https://picsum.photos/62",
                    totalDistanceText: "10.0km",
                    totalRunTimeText: "1:10:30",
                    averagePaceText: "7'00\"",
                    cadence: 138,
                    reactions: [],
                    dateText: "2025.10.15",
                    timeText: "오후 1:25"
                )
            )
        ),
        .init(
            id: "header-2025-9",
            kind: .monthHeader(year: "2025", month: "9월")
        ),
        .init(
            id: "feed-4",
            kind: .feed(
                .init(
                    feedID: 4,
                    dayText: "05일",
                    imageURL: "https://picsum.photos/202",
                    isMap: true,
                    userName: "혜준",
                    profileImageURL: "https://picsum.photos/63",
                    totalDistanceText: "3.24km",
                    totalRunTimeText: "0:20:14",
                    averagePaceText: "6'13\"",
                    cadence: 128,
                    reactions: [
                        ReactionViewState(emojiType: .fire, totalCount: 5, isReactedByMe: true, users: [])
                    ],
                    dateText: "2025.10.15",
                    timeText: "오후 1:25"
                )
            )
        )
    ]

    MyFeedView(feeds: feeds)
}


