//
//  FriendStatusSheet.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/15/25.
//

import SwiftUI

struct FriendStatusSheet: View {
    let friends: [Friend]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - 헤더
            HStack {
                Text("친구 두런 현황")
                    .typography(.t1_700)
                Spacer()
                Button {
                    // TODO: 친구 목록으로 이동 액션
                } label: {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(Color.gray800)
                }

            }
            .padding(.horizontal, 20)
            
            // MARK: - 친구 리스트
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(friends) { friend in
                        FriendRunningRow(
                            name: friend.name,
                            time: friend.time,
                            distance: friend.distance,
                            location: friend.location,
                            isMine: friend.isMine,
                            isRunning: friend.isRunning,
                            isSent: friend.isSent,
                            isFocus: friend.isFocus
                        )
                    }
                }
            }
        }
    }
}


#Preview {
    FriendStatusSheet(friends: [
        Friend(name: "민희", time: "1시간 전", distance: "5.01km", location: "광명", isMine: true, isRunning: true, isSent: false, isFocus: true),
        Friend(name: "해준", time: "30분 전", distance: "5.01km", location: "서울", isMine: false, isRunning: true, isSent: false, isFocus: false),
        Friend(name: "수연", time: "10시간 전", distance: "5.01km", location: "서울", isMine: false, isRunning: true, isSent: false, isFocus: false),
        Friend(name: "달리는하니", time: nil, distance: nil, location: nil, isMine: false, isRunning: false, isSent: false, isFocus: false),
        Friend(name: "땡땡", time: nil, distance: nil, location: nil, isMine: false, isRunning: false, isSent: true, isFocus: false)
    ])
}
