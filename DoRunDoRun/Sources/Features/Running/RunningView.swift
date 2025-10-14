import SwiftUI
import ComposableArchitecture

struct RunningView: View {
    let store: StoreOf<RunningFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    Spacer()
                    Text("러닝")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .navigationTitle("러닝")
            }
        }
    }
}
