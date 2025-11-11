//
//  FeedContentView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/1/25.
//

import ComposableArchitecture
import SwiftUI

struct FeedContentView: View {
    private let feed: FeedViewModel
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onSave: (() -> Void)?
    var onReaction: ((Emoji) -> Void)?

    @State private var showEmojiPicker = false
    @State private var showReactionDetail = false

    init(
        feed: FeedViewModel,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onSave: (() -> Void)? = nil,
        onReaction: ((Emoji) -> Void)? = nil
    ) {
        self.feed = feed
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onSave = onSave
        self.onReaction = onReaction
    }

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                HStack {
                Circle()
                    .frame(width: 32, height: 32)
                    .padding(.trailing, 8)

                Text(feed.userName)
                    .font(.pretendard(.medium, size: 16))
                    .padding(.trailing, 4)

                if feed.isMyFeed {
                    Text("나")
                        .font(.pretendard(.medium, size: 12))
                        .frame(width: 20, height: 20)
                        .background(Color.blue600)
                        .foregroundStyle(Color.gray0)
                        .clipShape(Circle())
                        .padding(.trailing, 8)
                }

                Text(feed.timeAgo)
                    .font(.pretendard(.medium, size: 14))
                    .foregroundStyle(Color.gray500)

                Spacer()

                Menu {
                    Button(action: {
                        onEdit?()
                    }) {
                        Label("수정하기", systemImage: "pencil")
                    }

                    Button(action: {
                        onSave?()
                    }) {
                        Label("이미지 저장", systemImage: "square.and.arrow.down")
                    }

                    Divider()

                    Button(role: .destructive, action: {
                        onDelete?()
                    }) {
                        Label("삭제하기", systemImage: "trash")
                    }
                } label: {
                    Image("three_dot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }

            ZStack(alignment: .topLeading) {
                // 배경 이미지
                if let imageURL = URL(string: feed.imageURL) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray300
                    }
                } else {
                    Color.gray300
                }

                VStack(alignment: .leading) {
                    if let time = feed.selfieTime {
                        Text(time)
                            .font(.pretendard(.regular, size: 12))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    HStack {
                        VStack(alignment: .leading) {
                            Text("달린 거리")
                                .font(.pretendard(.regular, size: 12))
                            Text(feed.totalDistance)
                                .font(.pretendard(.bold, size: 28))
                                .padding(.bottom, 12)

                            Text("평균 페이스")
                                .font(.pretendard(.regular, size: 12))
                            Text(feed.averagePace)
                                .font(.pretendard(.bold, size: 20))
                        }

                        VStack(alignment: .leading) {
                            Text("달린 시간")
                                .font(.pretendard(.regular, size: 12))
                            Text(feed.totalRunTime)
                                .font(.pretendard(.bold, size: 28))
                                .padding(.bottom, 12)

                            Text("평균 케이던스")
                                .font(.pretendard(.regular, size: 12))
                            Text(feed.cadence)
                                .font(.pretendard(.bold, size: 20))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
                .foregroundStyle(Color.white)
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
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.vertical, 20)

            ReactionView

            Spacer()
            }
            .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView(onEmojiSelected: { emoji in
                onReaction?(emoji)
                showEmojiPicker = false
            })
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        }
            .sheet(isPresented: $showReactionDetail) {
                ReactionDetailView(reactions: feed.reactions)
            }
        }
    }

    @ViewBuilder
    var ReactionView: some View {
        HStack {
            ForEach(feed.reactions.prefix(3), id: \.emojiType) { reaction in
                HStack(spacing: 2) {
                    Image(reaction.emojiType.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)

                    Text("\(reaction.totalCount)")
                        .frame(minWidth: 18)
                        .font(.pretendard(.medium, size: 14))
                }
                .padding(6)
                .background(Color.gray50)
                .clipShape(Capsule())
                .onTapGesture {
                    print("Tap on \(reaction.emojiType.rawValue)")
                }
                .onLongPressGesture {
                    print("Long press on \(reaction.emojiType.rawValue)")
                    showReactionDetail = true
                }
            }

            if feed.reactions.count > 3 {
                Button(action: {
                    showReactionDetail = true
                }) {
                    Text("+\(feed.reactions.count - 3)")
                        .font(.pretendard(.medium, size: 14))
                        .frame(width: 52, height: 32)
                        .foregroundStyle(Color.black)
                        .background(Color.gray50)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button(action: {
                showEmojiPicker = true
            }) {
                Image("emoji_more")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background(Color.gray50)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }
}

struct EmojiPickerView: View {
    let onEmojiSelected: (Emoji) -> Void

    let emojis: [Emoji] = [.SURPRISE, .HEART, .FIRE, .THUMBS_UP, .CONGRATS]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                ForEach(emojis, id: \.self) { emoji in
                    Button(action: {
                        onEmojiSelected(emoji)
                    }) {
                        Image(emoji.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 56, height: 56)
                    }
                }
            }
            .padding(.vertical, 32)
        }
    }
}
