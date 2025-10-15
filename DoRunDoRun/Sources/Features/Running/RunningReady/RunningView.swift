import SwiftUI
import ComposableArchitecture
import NMapsMap

struct RunningView: View {
    let store: StoreOf<RunningFeature>
    @State private var sheetOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                // MARK: - 지도
                RunningReadyMapView(latitude: 37.5665, longitude: 126.9780)
                    .ignoresSafeArea(edges: .top)
                
                // MARK: - 시트
                FriendStatusSheet(
                    friends: store.friends,
                    sheetOffset: $sheetOffset,
                    currentOffset: $currentOffset
                )
                .zIndex(2)

                // MARK: - 버튼
                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray0.opacity(0),
                            Color.gray0
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    .overlay(
                        AppButton(title: "오늘의 러닝 시작") {
                            // TODO: 러닝 중으로 변환 액션
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    )
                }
                .zIndex(3)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    RunningView(store: Store(initialState: RunningFeature.State()) {
        RunningFeature()
    })
}
