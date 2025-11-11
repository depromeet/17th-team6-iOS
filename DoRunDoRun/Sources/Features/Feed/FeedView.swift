import SwiftUI
import ComposableArchitecture

struct FeedView: View {
    let store: StoreOf<FeedFeature>

    var body: some View {
        @Perception.Bindable var store = store

        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    NavigationBar("인증피드")

                    DayInfoView(store.weekDayInfos, weekOfMonth: store.currentWeekOfMonth)

                    Divider()

                    ZStack {
                        if store.viewModel.feedList.isEmpty == false {
                            List {
                                if let userSummary = store.viewModel.userSummary {
                                    Button(action: {
                                        store.send(.tapCertificateFriends)
                                    }) {
                                        CertificateFriendsView(userSummary)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowSeparator(.hidden)
                                }

                                ForEach(store.viewModel.feedList, id: \.feedID) { feed in
                                    Button(action: { store.send(.tapFeedItem(feed)) }) {
                                        FeedContentView(feed: feed)
                                            .listRowSeparator(.hidden)
                                    }
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .listStyle(.plain)
                        } else {
                            VStack {
                                Spacer()
                                Image("empty_feed")
                                    .frame(width: 120, height: 120)
                                    .padding(.bottom, 24)

                                Text("정말 조용하네요..!")
                                    .font(.pretendard(.bold, size: 18))
                                    .padding(.bottom, 4)

                                Text("지금 첫 러닝을 인증해보세요!")
                                    .font(.pretendard(.regular, size: 14))
                                Spacer()
                            }

                        }

                        VStack(alignment: .trailing) {
                            Spacer()
                            HStack {
                                Spacer()

                                Button(action: { store.send(.tapUploadButton) }) {
                                    Image("feed_plus")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(14)
                                        .background(Color.blue600)
                                        .clipShape(Circle())
                                        .shadow(radius: 8)
                                }
                            }
                            .padding(.bottom, 16)
                            .padding(.trailing, 20)
                        }
                    }

                    Spacer()

                }
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(
                                item: $store.scope(
                                    state: \.destination?.feedDetail,
                                    action: \.destination.feedDetail
                                )
                            ) { (store: StoreOf<FeedDetailFeature>) in
                                FeedDetailView(store: store)
                            }
                .navigationDestination(
                                item: $store.scope(
                                    state: \.destination?.uploadFeed,
                                    action: \.destination.uploadFeed
                                )
                            ) { (store: StoreOf<UploadFeedFeature>) in
                                UploadFeedView(store: store)
                            }
                .navigationDestination(
                                item: $store.scope(
                                    state: \.destination?.certificateFriendsList,
                                    action: \.destination.certificateFriendsList
                                )
                            ) { (store: StoreOf<CertificateFriendsListFeature>) in
                                CertificateFriendsListView(store: store)
                            }
            }
            .onAppear {
                store.send(.fetchFeed)
            }
            
        }
    }


    @ViewBuilder
    func DayInfoView(_ dayInfos: [FeedDayInfo], weekOfMonth: Int) -> some View {
        VStack {
            HStack {
                Text("10월 \(weekOfMonth)주차")
                    .font(.pretendard(.bold, size: 15))

                Spacer()

                HStack(spacing: 8) {
                    Button(action: {
                        store.send(.previousWeek)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray700)
                    }

                    Button(action: {
                        store.send(.nextWeek)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray700)
                    }
                }
            }
            .padding(.bottom, 12)

            HStack {
                ForEach(dayInfos, id: \.weekDay) { dayInfo in
                    VStack {
                        Text(dayInfo.weekDay.title)
                            .font(.pretendard(.medium, size: 14))
                            .foregroundStyle(Color.gray500)
                            .padding(.bottom, 8)

                        Button(action: { store.send(.selectDate(dayInfo.date)) }) {
                            if dayInfo.isItToday {
                                Text("오늘")
                                    .frame(width: 40, height: 28)
                                    .font(.pretendard(.medium, size: 14))
                                    .foregroundStyle(Color.gray0)
                                    .background(Color.blue600)
                                    .clipShape(Capsule())
                            } else {
                                Text("\(dayInfo.day)")
                                    .frame(height: 28)
                                    .font(.pretendard(.medium, size: 14))
                                    .foregroundStyle(Color.gray900)
                            }
                        }

                        Text(dayInfo.count > 0 ? "+\(dayInfo.count)" : "0")
                            .font(.pretendard(.medium, size: 12))
                            .foregroundStyle(dayInfo.count > 0 ? Color.blue600 : Color.gray400)
                            .frame(height: 28)
                    }
                    .frame(minWidth: 40)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    func CertificateFriendsView(_ userSummary: UserSummary) -> some View {
        HStack {
            ZStack(alignment: .leading) {
                Text("+\(userSummary.friendCount)")
                    .foregroundStyle(Color.blue600)
                    .font(.pretendard(.medium, size: 14))
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color.blue100)
                    .clipShape(Capsule())
                    .zIndex(1)

                Image("feed_friends")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .padding(.leading, 24)
            }

            Text("\(userSummary.friendCount)명이 인증했어요!")
                .font(.pretendard(.medium, size: 14))
                .foregroundStyle(Color.gray700)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    let today = Date()
    FeedView(store: Store(
        initialState: FeedFeature.State(
            weekDayInfos: [
                FeedDayInfo(weekDay: .sun, day: 11, date: today, isItToday: false, count: 8),
                FeedDayInfo(weekDay: .mon, day: 12, date: today, isItToday: false, count: 6),
                FeedDayInfo(weekDay: .tue, day: 13, date: today, isItToday: false, count: 0),
                FeedDayInfo(weekDay: .wed, day: 14, date: today, isItToday: false, count: 0),
                FeedDayInfo(weekDay: .thu, day: 15, date: today, isItToday: true, count: 11),
                FeedDayInfo(weekDay: .fri, day: 16, date: today, isItToday: false, count: 4),
                FeedDayInfo(weekDay: .sat, day: 17, date: today, isItToday: false, count: 0)
            ]
        ),
        reducer: {
            FeedFeature()
        }))
}
