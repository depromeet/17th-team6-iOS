import Foundation
import ComposableArchitecture

struct Friend: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let time: String?
    let distance: String?
    let location: String?
    let isMine: Bool
    let isRunning: Bool
    let isSent: Bool
    let isFocus: Bool
}

@Reducer
struct RunningFeature {
    @ObservableState
    struct State: Equatable {
        var friends: [Friend] = mockFriends
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

extension RunningFeature {
    static let mockFriends: [Friend] = [
        Friend(name: "민희", time: "1시간 전", distance: "5.01km", location: "광명", isMine: true, isRunning: true, isSent: false, isFocus: true),
        Friend(name: "해준", time: "30분 전", distance: "5.01km", location: "서울", isMine: false, isRunning: true, isSent: false, isFocus: false),
        Friend(name: "수연", time: "10시간 전", distance: "5.01km", location: "서울", isMine: false, isRunning: true, isSent: false, isFocus: false),
        Friend(name: "달리는하니", time: nil, distance: nil, location: nil, isMine: false, isRunning: false, isSent: false, isFocus: false),
        Friend(name: "땡땡", time: nil, distance: nil, location: nil, isMine: false, isRunning: false, isSent: true, isFocus: false)
    ]
}
