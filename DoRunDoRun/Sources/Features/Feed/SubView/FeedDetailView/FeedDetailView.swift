//
//  FeedDetailView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/6/25.
//

import SwiftUI
import ComposableArchitecture

struct FeedDetailView: View {
    let store: StoreOf<FeedDetailFeature>

    var body: some View {
        VStack {
            FeedContentView(feed: store.feedViewModel)
                .padding(.top, 40)
                .padding(.horizontal)
            Spacer()
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            print("설정")
                        }) {
                            Label("설정", systemImage: "gear")
                        }

                        Button(action: {
                            print("공유")
                        }) {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button(role: .destructive, action: {
                            print("삭제")
                        }) {
                            Label("삭제", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
    }
}

