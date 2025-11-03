//
//  RunningMapView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

import NMapsMap

/// 러닝 전, 러닝 중 화면에서 보여질 NaverMap
struct RunningMapView: UIViewRepresentable {
    var statuses: [FriendRunningStatusViewState]
    var focusedFriendID: Int?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - UIView 생성
    func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView(frame: .zero)

        // 지도 기본 UI 설정
        mapView.showZoomControls = false
        mapView.showLocationButton = false
        mapView.showScaleBar = false
        mapView.mapView.positionMode = .direction

        // 마커 추가 + 카메라 이동
        addMarkers(on: mapView.mapView, with: statuses, context: context)
        moveCamera(to: focusedFriendID, in: mapView.mapView)
        return mapView
    }

    // MARK: - UIView 갱신
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // 기존 마커 제거
        context.coordinator.markers.forEach { $0.mapView = nil }
        context.coordinator.markers.removeAll()

        // 새 마커 추가 및 카메라 갱신
        addMarkers(on: uiView.mapView, with: statuses, context: context)
        moveCamera(to: focusedFriendID, in: uiView.mapView)
    }

    // MARK: - Coordinator
    class Coordinator {
        var markers: [NMFMarker] = []
    }
}

// MARK: - Private Helpers
private extension RunningMapView {
    // TODO: [성능 최적화]
    // - 현재는 모든 친구 마커를 매번 새로 추가하고 삭제함.
    // - 화면(Viewport)에 보이는 영역 내의 친구만 표시하도록 개선 필요.
    // - 마커 클러스터링(근접 좌표 통합) 또는 캐싱 처리로 렌더링 부하 줄이기.
    // - 친구 위치 변화가 없을 경우 마커 재생성 방지.

    /// 친구들의 위치에 마커를 추가
    func addMarkers(on mapView: NMFMapView, with statuses: [FriendRunningStatusViewState], context: Context) {
        for status in statuses {
            guard let lat = status.latitude, let lng = status.longitude else { continue }

            let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))

            Task { @MainActor in
                await Task.yield()
                let customView = FriendMarkerView(
                    name: status.name,
                    profileImageURL: status.profileImageURL,
                    isRunning: status.isRunning,
                    isFocused: status.id == focusedFriendID
                )
                let markerImage = customView.snapshot()
                marker.iconImage = NMFOverlayImage(image: markerImage)
                marker.mapView = mapView
                context.coordinator.markers.append(marker)
            }
        }
    }

    /// 포커스된 친구로 카메라 이동
    func moveCamera(to focusedID: Int?, in mapView: NMFMapView) {
        guard
            let focusedID,
            let friend = statuses.first(where: { $0.id == focusedID }),
            let lat = friend.latitude,
            let lng = friend.longitude
        else { return }

        // 1. 친구 좌표 → 지도 좌표 변환
        let latLng = NMGLatLng(lat: lat, lng: lng)
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

