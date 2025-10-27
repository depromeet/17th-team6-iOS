import SwiftUI
import ComposableArchitecture
import NMapsMap

/// 러닝 전체 화면 (Ready → Countdown → Active)
struct RunningView: View {
    let store: StoreOf<RunningFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                // 공통 지도 View
                RunningMapView(
                    statuses: store.ready.statuses,
                    focusedFriendID: store.ready.focusedFriendID
                )
                .ignoresSafeArea(
                    edges: store.phase == .ready ? .top : [.top, .bottom]
                )

                // Phase별 전환
                switch store.phase {
                case .ready:
                    RunningReadyView(store: store.scope(state: \.ready, action: \.ready))

                case .countdown:
                    RunningCountdownView(store: store.scope(state: \.countdown, action: \.countdown))
                        .ignoresSafeArea()
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))

                case .active:
                    RunningActiveView(store: store.scope(state: \.active, action: \.active))
                        .ignoresSafeArea()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

#Preview {
    RunningView(
        store: Store(initialState: RunningFeature.State()) {
            RunningFeature()
        }
    )
}
