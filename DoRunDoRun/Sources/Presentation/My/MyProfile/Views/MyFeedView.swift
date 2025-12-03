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
            feedGridSection
        }
        .background(Color.gray0)
    }
}

// MARK: - Subviews
private extension MyFeedView {
    /// 피드 그리드 섹션
    var feedGridSection: some View {
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
                    .onAppear { handleOnAppear(feed) }
                }
            }

            // 로딩 표시 섹션
            if isLoading { loadingSection }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 24)
    }

    /// 로딩 인디케이터 뷰
    var loadingSection: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }
}

// MARK: - Helpers
private extension MyFeedView {
    /// 마지막 셀 도달 시 다음 페이지 로드 트리거
    func handleOnAppear(_ feed: SelfieFeedViewState) {
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
