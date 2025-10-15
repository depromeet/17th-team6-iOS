import SwiftUI
import ComposableArchitecture

struct RunningSummaryView: View {
    let store: StoreOf<RunningSummaryFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    Spacer()
                    Text("러닝 완료")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .navigationTitle("러닝 완료")
            }
        }
    }
}

#Preview {
    RunningSummaryView(
        store: Store(
            initialState: RunningSummaryFeature.State(),
            reducer: { RunningSummaryFeature() }
        )
    )
}
