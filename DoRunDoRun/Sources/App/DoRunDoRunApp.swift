import SwiftUI
import ComposableArchitecture

@main
struct DoRunDoRunApp: App {
    // AppDelegate 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            FriendListView(
                store: Store(initialState: FriendListFeature.State()) {
                    FriendListFeature()
                }
            )
        }
    }
}
