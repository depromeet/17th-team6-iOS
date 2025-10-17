import SwiftUI
import ComposableArchitecture
import NMapsMap

/// 러닝 시작 전 친구들의 위치와 상태를 표시하는 메인 화면(View)
///
/// `RunningReadyFeature`의 상태를 기반으로
/// 지도(`RunningReadyMapView`), 친구 현황 시트(`FriendStatusSheet`),
/// 그리고 "오늘의 러닝 시작" 버튼으로 구성됩니다.
struct RunningReadyView: View {
    let store: StoreOf<RunningReadyFeature>         // TCA Store (친구 정보, 포커스 상태 등 관리)
    @State private var sheetOffset: CGFloat = 0     // 시트의 현재 오프셋 (드래그 시 변동)
    @State private var currentOffset: CGFloat = 0   // 드래그 종료 시 기준 오프셋

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                mapSection
                friendSheet
                startButton
            }
            .onAppear(perform: focusOnMyself)
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Subviews
private extension RunningReadyView {

    /// 지도 섹션
    @ViewBuilder
    var mapSection: some View {
        RunningReadyMapView(
            friends: store.friends,
            focusedFriendID: store.focusedFriendID
        )
    }

    /// 친구 현황 시트 섹션
    @ViewBuilder
    var friendSheet: some View {
        FriendStatusSheet(
            friends: store.friends,
            focusedFriendID: store.focusedFriendID,
            sheetOffset: $sheetOffset,
            currentOffset: $currentOffset,
            onFriendTap: { id in
                store.send(.friendTapped(id))
            }
        )
        .zIndex(2)
    }

    /// “오늘의 러닝 시작” 버튼 섹션
    @ViewBuilder
    var startButton: some View {
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
                    // TODO: 러닝 시작 액션
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            )
        }
        .zIndex(3)
    }
}

// MARK: - Private Helpers
private extension RunningReadyView {
    /// 앱 진입 시 나 자신에게 카메라 포커싱
    func focusOnMyself() {
        if let myFriend = store.friends.first(where: { $0.isMine }) {
            store.send(.friendTapped(myFriend.id))
        }
    }
}

// MARK: - Preview
#Preview {
    RunningReadyView(store: Store(initialState: RunningReadyFeature.State()) {
        RunningReadyFeature()
    })
}
