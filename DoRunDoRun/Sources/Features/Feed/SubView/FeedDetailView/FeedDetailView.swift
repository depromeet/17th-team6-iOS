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
            FeedContentView(
                feed: store.feedViewModel,
                onEdit: { store.send(.change) },
                onDelete: { store.send(.delete) },
                onSave: { store.send(.save) }
            )
            .padding(.top, 40)
            .padding(.horizontal)
            Spacer()
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            store.send(.change)
                        }) {
                            Label("수정하기", systemImage: "pencil")
                        }

                        Button(action: {
                            store.send(.save)
                        }) {
                            Label("이미지 저장", systemImage: "square.and.arrow.down")
                        }

                        Divider()

                        Button(role: .destructive, action: {
                            store.send(.delete)
                        }) {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } label: {
                        Image("three_dot")
                            .renderingMode(.template)
                    }
                }
            }
    }
}

