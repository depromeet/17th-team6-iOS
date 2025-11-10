//
//  ReactionDetailView.swift
//  DoRunDoRun
//
//  Created by Claude on 11/10/25.
//

import SwiftUI

struct ReactionDetailView: View {
    let reactions: [FeedReaction]
    @State private var selectedEmoji: Emoji?
    @Environment(\.dismiss) var dismiss

    private var totalReactionCount: Int {
        reactions.reduce(0) { $0 + $1.totalCount }
    }

    private var filteredUsers: [ReactionUserViewModel] {
        var users: [ReactionUserViewModel] = []

        for reaction in reactions {
            if let selected = selectedEmoji {
                if reaction.emojiType == selected {
                    for user in reaction.users {
                        users.append(ReactionUserViewModel(
                            nickname: user.nickname,
                            profileImageURL: user.profileImageURL,
                            isMe: user.isMe,
                            emojiType: reaction.emojiType
                        ))
                    }
                }
            } else {
                for user in reaction.users {
                    users.append(ReactionUserViewModel(
                        nickname: user.nickname,
                        profileImageURL: user.profileImageURL,
                        isMe: user.isMe,
                        emojiType: reaction.emojiType
                    ))
                }
            }
        }

        return users.sorted { user1, user2 in
            if user1.isMe != user2.isMe {
                return user1.isMe
            }
            return user1.nickname < user2.nickname
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 드래그 인디케이터
            Capsule()
                .fill(Color.gray100)
                .frame(width: 39, height: 5)
                .padding(.vertical, 16)

            VStack(alignment: .leading, spacing: 16) {
                // 헤더
                HStack(spacing: 4) {
                    Text("반응")
                        .font(.pretendard(.bold, size: 20))
                        .foregroundStyle(Color.gray900)

                    Text("\(totalReactionCount)")
                        .font(.pretendard(.bold, size: 20))
                        .foregroundStyle(Color.gray500)
                }
                .padding(.horizontal, 20)

                // 이모지 필터
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(reactions, id: \.emojiType) { reaction in
                            ReactionChip(
                                emoji: reaction.emojiType,
                                count: reaction.totalCount,
                                isSelected: selectedEmoji == reaction.emojiType,
                                action: {
                                    if selectedEmoji == reaction.emojiType {
                                        selectedEmoji = nil
                                    } else {
                                        selectedEmoji = reaction.emojiType
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // 사용자 리스트
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredUsers, id: \.id) { user in
                            UserReactionRow(user: user)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .presentationDetents([.height(516)])
        .presentationDragIndicator(.hidden)
    }
}

struct ReactionChip: View {
    let emoji: Emoji
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Image(emoji.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)

                Text("\(count)")
                    .font(.pretendard(.medium, size: 14))
                    .foregroundStyle(isSelected ? Color.white : Color.gray700)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .frame(minWidth: 52, minHeight: 32)
            .background(isSelected ? Color.blue600 : Color.gray50)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue600 : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct UserReactionRow: View {
    let user: ReactionUserViewModel

    var body: some View {
        HStack(spacing: 12) {
            // 프로필 이미지
            Circle()
                .fill(Color.gray50)
                .frame(width: 52, height: 52)

            // 닉네임
            HStack(spacing: 4) {
                Text(user.nickname)
                    .font(.pretendard(.bold, size: 18))
                    .foregroundStyle(Color.gray900)

                if user.isMe {
                    Text("나")
                        .font(.pretendard(.medium, size: 12))
                        .foregroundStyle(Color.white)
                        .frame(width: 20, height: 20)
                        .background(Color.blue600)
                        .clipShape(Circle())
                }
            }

            Spacer()
        }
        .padding(.vertical, 12)
    }
}

struct ReactionUserViewModel: Identifiable {
    let id = UUID()
    let nickname: String
    let profileImageURL: String
    let isMe: Bool
    let emojiType: Emoji
}

#Preview {
    ReactionDetailView(reactions: [
        FeedReaction(
            emojiType: .SURPRISE,
            totalCount: 3,
            users: [
                FeedReactionUser(
                    userID: 1,
                    nickname: "비락식혜",
                    profileImageURL: "",
                    isMe: true,
                    reactedAt: Date()
                ),
                FeedReactionUser(
                    userID: 2,
                    nickname: "버터꿀맥주",
                    profileImageURL: "",
                    isMe: false,
                    reactedAt: Date()
                ),
                FeedReactionUser(
                    userID: 3,
                    nickname: "와사비맛땅콩",
                    profileImageURL: "",
                    isMe: false,
                    reactedAt: Date()
                )
            ]
        ),
        FeedReaction(
            emojiType: .HEART,
            totalCount: 2,
            users: [
                FeedReactionUser(
                    userID: 4,
                    nickname: "불닭마요",
                    profileImageURL: "",
                    isMe: false,
                    reactedAt: Date()
                ),
                FeedReactionUser(
                    userID: 5,
                    nickname: "치토스",
                    profileImageURL: "",
                    isMe: false,
                    reactedAt: Date()
                )
            ]
        )
    ])
}
