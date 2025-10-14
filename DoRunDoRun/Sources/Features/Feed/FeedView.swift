import SwiftUI
import ComposableArchitecture

struct FeedView: View {
    let store: StoreOf<FeedFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    Spacer()
                    Text("인증 피드")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .navigationTitle("인증 피드")
            }
        }
    }
}
