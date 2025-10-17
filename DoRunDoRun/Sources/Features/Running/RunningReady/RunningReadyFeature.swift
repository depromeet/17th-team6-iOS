import Foundation
import ComposableArchitecture

struct Friend: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let time: String?
    let distance: String?
    let location: String?
    let latitude: Double
    let longitude: Double
    let isMine: Bool
    let isRunning: Bool
    let isSent: Bool
}

@Reducer
struct RunningReadyFeature {
    @ObservableState
    struct State: Equatable {
        var friends: [Friend] = mockFriends
        var focusedFriendID: UUID? = nil
    }

    enum Action: Equatable {
        case friendTapped(UUID)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .friendTapped(id):
                state.focusedFriendID = id
                return .none
            }
        }
    }
}

extension RunningReadyFeature {
    static let mockFriends: [Friend] = [
        Friend(name: "민희", time: "1시간 전", distance: "5.01km", location: "광명", latitude: 37.4784, longitude: 126.8641, isMine: true, isRunning: true, isSent: false),
        Friend(name: "해준", time: "30분 전", distance: "5.01km", location: "서울", latitude: 37.5665, longitude: 126.9780, isMine: false, isRunning: true, isSent: false),
        Friend(name: "수연", time: "10시간 전", distance: "5.01km", location: "서울", latitude: 37.5700, longitude: 126.9820, isMine: false, isRunning: true, isSent: false),
        Friend(name: "달리는하니", time: nil, distance: nil, location: "인천", latitude: 37.4563, longitude: 126.7052, isMine: false, isRunning: false, isSent: false),
        Friend(name: "땡땡", time: nil, distance: nil, location: "부천", latitude: 37.4980, longitude: 126.7830, isMine: false, isRunning: false, isSent: true)
    ]
}

