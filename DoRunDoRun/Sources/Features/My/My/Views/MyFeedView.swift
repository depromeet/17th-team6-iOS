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
