//
//  CertificateFriendsListView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import SwiftUI
import ComposableArchitecture

struct CertificateFriendsListView: View {
    let store: StoreOf<CertificateFriendsListFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text("인증목록 \(store.friends.count)")
                    .font(.pretendard(.bold, size: 22))
                    .foregroundStyle(Color.gray900)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(store.friends, id: \.name) { friend in
                            FriendCertificateRow(friend: friend)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct FriendCertificateRow: View {
    let friend: FriendCertificate

    var body: some View {
        HStack(spacing: 12) {
            Image("ic_face")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.blue400)
                .background(Color.blue100)
                .clipShape(Circle())

            HStack(spacing: 8) {
                Text(friend.name)
                    .font(.pretendard(.semiBold, size: 16))
                    .foregroundStyle(Color.gray900)

                if friend.name == "비락식혜" { // TODO: 본인 인증 어떻게 앎?
                    Text("나")
                        .font(.pretendard(.medium, size: 12))
                        .frame(width: 20, height: 20)
                        .background(Color.blue600)
                        .foregroundStyle(Color.gray0)
                        .clipShape(Circle())
                }


                Text("\(friend.daysAgo)일 전")
                    .font(.pretendard(.regular, size: 14))
                    .foregroundStyle(Color.gray500)
            }


            Spacer()
        }
    }
}

#Preview {
    CertificateFriendsListView(store: .init(
        initialState: .init(),
        reducer: {
            CertificateFriendsListFeature()
        }
    ))
}
