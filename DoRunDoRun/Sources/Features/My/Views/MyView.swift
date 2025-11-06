import SwiftUI
import ComposableArchitecture

struct MyView: View {
    let store: StoreOf<MyFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    Spacer()
                    Text("마이")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .navigationTitle("마이")
            }
        }
    }
}
