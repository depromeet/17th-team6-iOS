import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Perception.Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                    RunningView(store: store.scope(state: \.running, action: \.running))
                        .tabItem { Label("러닝", systemImage: "figure.run") }
                        .tag(AppFeature.State.Tab.running)
                    
                    FeedView(store: store.scope(state: \.feed, action: \.feed))
                        .tabItem { Label("피드", systemImage: "list.bullet.rectangle") }
                        .tag(AppFeature.State.Tab.feed)
                    
                    MyView(store: store.scope(state: \.my, action: \.my))
                        .tabItem { Label("마이", systemImage: "person.circle") }
                        .tag(AppFeature.State.Tab.my)
                }
            }
        }
    }
}
