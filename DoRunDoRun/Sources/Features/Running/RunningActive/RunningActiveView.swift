import SwiftUI
import ComposableArchitecture

struct RunningActiveView: View {
    let store: StoreOf<RunningActiveFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    Spacer()
                    Text("러닝 중")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .navigationTitle("러닝 중")
            }
        }
    }
}

#Preview {
    RunningActiveView(
        store: Store(
            initialState: RunningActiveFeature.State(),
            reducer: { RunningActiveFeature() }
        )
    )
}
