import SwiftUI
import ComposableArchitecture
import NMapsMap

/// 러닝 전체 화면 (Ready → Countdown → Active)
struct RunningView: View {
    @Perception.Bindable var store: StoreOf<RunningFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                phaseBackground
                phaseContent
            }
            .overlay {
                if store.active.isShowingStopConfirm {
                    ZStack {
                        Color.dimLight.ignoresSafeArea()
                        ActionPopupView(
                            title: "러닝 기록 종료",
                            message: "이대로 기록을 종료하시겠어요?",
                            actionTitle: "기록 종료",
                            cancelTitle: "취소",
                            style: .destructive,
                            onAction: { store.send(.active(.stopConfirmButtonTapped)) },
                            onCancel: { store.send(.active(.stopCancelButtonTapped)) }
                        )
                    }
                }
            }
            .navigationDestination(item: $store.scope(state: \.runningDetail, action: \.runningDetail)
            ) { runningDetailStore in
                    RunningDetailView(store: runningDetailStore)
            }
        }
    }
}

private extension RunningView {
    @ViewBuilder
    var phaseBackground: some View {
        switch store.phase {
        case .ready:
            RunningMapView(
                phase: store.phase,
                statuses: store.ready.statuses,
                focusedFriendID: store.ready.focusedFriendID,
                isFollowingLocation: store.ready.isFollowingUserLocation,
                onMapGestureDetected: {
                    store.send(.ready(.mapGestureDetected))
                },
                userLocation: store.ready.userLocation,
                runningCoordinates: []
            )
            .ignoresSafeArea(edges: .top)
        case .countdown:
            Color.blue600
                .ignoresSafeArea()
        case .active:
            if store.active.isRunningPaused {
                Color.gray0
                    .ignoresSafeArea()
            } else {
                Color.blue600
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    var phaseContent: some View {
        switch store.phase {
        case .ready:
            RunningReadyView(store: store.scope(state: \.ready, action: \.ready))
        case .countdown:
            RunningCountdownView(store: store.scope(state: \.countdown, action: \.countdown))
                .ignoresSafeArea()
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
        case .active:
            RunningActiveView(store: store.scope(state: \.active, action: \.active))
                .toolbar(.hidden, for: .tabBar)
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
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
