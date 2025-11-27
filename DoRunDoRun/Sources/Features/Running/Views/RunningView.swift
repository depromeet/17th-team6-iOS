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
                    isFollowingLocation: store.phase == .ready
                        ? store.ready.isFollowingUserLocation
                        : store.active.isFollowingLocation,
                    onMapGestureDetected: {
                        if store.phase == .ready {
                            store.send(.ready(.mapGestureDetected))
                        } else {
                            store.send(.active(.mapGestureDetected))
                        }
                    },
                    userLocation: store.ready.userLocation,
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

// MARK: - Navigation Destinations
extension RunningView {
    @ViewBuilder
    func pathDestination(for pathState: RunningReadyFeature.Path.State) -> some View {
        switch pathState {
        case .friendList(let friendListState):
            FriendListView(
                store: Store(
                    initialState: friendListState,
                    reducer: { FriendListFeature() }
                )
            )
        case .friendProfile(let friendProfileState):
            FriendProfileView(
                store: Store(
                    initialState: friendProfileState,
                    reducer: { FriendProfileFeature() }
                )
            )
        case .myProfile:
            Text("My Profile - TODO")
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
