//
//  RunningReadyMapView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/15/25.
//

import SwiftUI
import NMapsMap

/// 친구들의 위치를 표시하는 Naver 지도 (View)
///
/// SwiftUI에서 NMFNaverMapView를 사용할 수 있도록 UIViewRepresentable로 래핑한 컴포넌트입니다.
/// `Friend` 리스트를 기반으로 지도에 마커를 추가하고, 특정 친구를 포커싱할 수 있습니다.
struct RunningReadyMapView: UIViewRepresentable {
    var friends: [Friend]          // 지도에 표시할 친구 목록
    var focusedFriendID: UUID?     // 카메라가 포커싱할 친구의 ID

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - UIView 생성
    func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView(frame: .zero)
        
        // 지도 기본 UI 설정
        mapView.showZoomControls = false
        mapView.showLocationButton = true
        mapView.mapView.positionMode = .direction

        // 초기 마커 추가 및 카메라 이동
        addMarkers(on: mapView.mapView, with: friends, context: context)
        moveCamera(to: focusedFriendID, in: mapView.mapView)
        return mapView
    }

    // MARK: - UIView 갱신
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // 기존 마커 제거
        context.coordinator.markers.forEach { $0.mapView = nil }
        context.coordinator.markers.removeAll()
        
        // 새 마커 추가 및 카메라 갱신
        addMarkers(on: uiView.mapView, with: friends, context: context)
        moveCamera(to: focusedFriendID, in: uiView.mapView)
    }

    // MARK: - Coordinator
    class Coordinator {
        var markers: [NMFMarker] = []
    }
}

// MARK: - Private Helpers
private extension RunningReadyMapView {

    /// 친구들의 위치에 마커를 추가하는 함수
    ///
    /// - Parameters:
    ///   - mapView: Naver 지도 객체
    ///   - friends: 마커를 표시할 친구 리스트
    ///   - context: UIViewRepresentable의 컨텍스트
    func addMarkers(on mapView: NMFMapView, with friends: [Friend], context: Context) {
        for friend in friends {
            let marker = NMFMarker(position: NMGLatLng(lat: friend.latitude, lng: friend.longitude))

            // SwiftUI View(FriendMarkerView) → UIImage 변환 후 마커 아이콘으로 설정
            // SwiftUI 렌더링 사이클 중 즉시 snapshot을 호출하면
            // AttributeGraph 순환(cycle detected) 오류가 발생하므로,
            // 다음 runloop로 미뤄 안전하게 렌더링하도록 비동기 처리
            Task { @MainActor in
                await Task.yield()
                let customView = FriendMarkerView(
                    profileImage: nil,
                    name: friend.name,
                    isRunning: friend.isRunning,
                    isFocus: friend.id == focusedFriendID
                )
                let markerImage = customView.snapshot()

                marker.iconImage = NMFOverlayImage(image: markerImage)
                marker.mapView = mapView
                context.coordinator.markers.append(marker)
            }
        }
    }

    /// 포커싱된 친구 위치로 카메라를 이동시킴
    ///
    /// - Parameters:
    ///   - id: 포커싱할 친구의 ID
    ///   - mapView: Naver 지도 객체
    ///
    /// 카메라가 친구의 마커를 완전히 덮지 않도록
    /// Y 좌표를 약간 올린 위치로 이동시켜 가시성을 확보합니다.
    func moveCamera(to id: UUID?, in mapView: NMFMapView) {
        guard let id,
              let friend = friends.first(where: { $0.id == id }) else { return }

        // 1. 친구 좌표 → 지도 좌표 변환
        let latLng = NMGLatLng(lat: friend.latitude, lng: friend.longitude)
        let projection = mapView.projection

        // 2. 화면 좌표로 변환 후, 위쪽으로 150pt 이동
        let screenPoint = projection.point(from: latLng)
        let adjustedPoint = CGPoint(x: screenPoint.x, y: screenPoint.y + 150)

        // 3. 다시 지도 좌표로 변환
        let adjustedLatLng = projection.latlng(from: adjustedPoint)

        // 4. 카메라 이동 애니메이션 적용
        let update = NMFCameraUpdate(position: NMFCameraPosition(adjustedLatLng, zoom: 14))
        update.animation = .easeIn
        mapView.moveCamera(update)
    }
}

// MARK: - Preview
#Preview {
    RunningReadyMapView(
        friends: RunningReadyFeature.mockFriends,
        focusedFriendID: RunningReadyFeature.mockFriends.first?.id
    )
}
