import SwiftUI
import ComposableArchitecture
import NMapsMap

/// 러닝 전체 화면 (Ready → Countdown → Active)
struct RunningView: View {
    @Perception.Bindable var store: StoreOf<RunningFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                // 공통 지도 View
                RunningMapView(
                    phase: store.phase,
                    statuses: store.ready.statuses,
                    focusedFriendID: store.ready.focusedFriendID,
                    myLocation: store.ready.myLocation,
                    isFollowingLocation: store.active.isFollowingLocation,
                    onMapGestureDetected: { store.send(.active(.mapGestureDetected)) },
                    runningCoordinates: store.active.routeCoordinates
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
            .overlay {
                if store.active.isShowingStopConfirm {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
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

#Preview {
    RunningView(
        store: Store(initialState: RunningFeature.State()) {
            RunningFeature()
        }
    )
}
