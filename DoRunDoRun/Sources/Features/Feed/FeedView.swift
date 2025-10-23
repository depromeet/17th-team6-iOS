import SwiftUI
import ComposableArchitecture

struct FeedView: View {
    let store: StoreOf<FeedFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    NavigationBar("인증피드")
                    Spacer()
                }
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}
