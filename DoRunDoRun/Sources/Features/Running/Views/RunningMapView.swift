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
    
    enum CameraZoomLevel {
        static let min: Double = 6
        static let max: Double = 18
        static let `default`: Double = 16
        static let focusedFriend: Double = 14
    }
    
    var phase: RunningPhase
    
    var statuses: [FriendRunningStatusViewState]
    var focusedFriendID: Int?
    
    var runningCoordinates: [RunningCoordinateViewState]

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
        
        mapView.mapView.minZoomLevel = CameraZoomLevel.min
        mapView.mapView.maxZoomLevel = CameraZoomLevel.max

        // 마커 추가 + 카메라 이동
        addMarkers(on: mapView.mapView, with: statuses, context: context)
        moveCamera(to: focusedFriendID, in: mapView.mapView)
        
        // 경로 오버레이 초기 생성 + 스타일
        context.coordinator.routeOverlay = makeRouteOverlay()
        
        return mapView
    }

    // MARK: - UIView 갱신
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        switch phase {
        case .ready:
            // 기존 마커 제거
            context.coordinator.markers.forEach { $0.mapView = nil }
            context.coordinator.markers.removeAll()

            // 새 마커 추가 및 카메라 갱신
            addMarkers(on: uiView.mapView, with: statuses, context: context)
            moveCamera(to: focusedFriendID, in: uiView.mapView)
            
        case .countdown: return
        case .active:
            updateForActive(uiView, context: context)
        }
    }

    // MARK: - Coordinator
    class Coordinator {
        var markers: [NMFMarker] = []
        
        var routeOverlay: NMFPath?            // 경로 오버레이 보관
        var didCenterInitialCamera = false    // Active 최초 1회 카메라 센터링 여부
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
                    profileImage: nil,
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
        let update = NMFCameraUpdate(position: NMFCameraPosition(adjustedLatLng, zoom: CameraZoomLevel.focusedFriend))
        update.animation = .easeIn
        mapView.moveCamera(update)
    }
}

// MARK: - RunningActive

private extension RunningMapView {
    /// Active 단계에서 지도 상태를 갱신합니다.
    func updateForActive(_ uiView: NMFNaverMapView, context: Context) {
        // Active 진입 시 최초 1회만 카메라 센터링
        if !context.coordinator.didCenterInitialCamera, let first = runningCoordinates.first {
            centerCamera(on: first, in: uiView.mapView)
            context.coordinator.didCenterInitialCamera = true
        }

        // 이후에는 경로만 갱신
        updateRunningRoute(on: uiView.mapView, context: context)
    }
    
    /// 주어진 러닝 좌표를 기준으로 카메라를 가운데로 이동
    func centerCamera(
        on coordinate: RunningCoordinateViewState,
        in mapView: NMFMapView,
        zoom: Double = CameraZoomLevel.default
    ) {
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let update = NMFCameraUpdate(position: NMFCameraPosition(latLng, zoom: zoom))
        update.animation = .easeIn
        mapView.moveCamera(update)
    }
    
    /// runningCoordinates를 이용해 경로를 업데이트한다.
    func updateRunningRoute(on mapView: NMFMapView, context: Context) {
        // 좌표가 없으면 기존 경로 제거
        guard !runningCoordinates.isEmpty else {
            context.coordinator.routeOverlay?.mapView = nil
            context.coordinator.routeOverlay = nil
            return
        }

        // 1) 없으면 생성
        if context.coordinator.routeOverlay == nil {
            context.coordinator.routeOverlay = makeRouteOverlay()
        }
        
        // 2) 라인 구성
        let latlngs = runningCoordinates
            .map {
                NMGLatLng(lat: $0.latitude, lng: $0.longitude)
            } as [AnyObject]
        let line = NMGLineString(points: latlngs)
        
        // 3) 경로 적용
        context.coordinator.routeOverlay?.path = line
        
        // 4) 지도에 부착
        context.coordinator.routeOverlay?.mapView = mapView

    }
    
    /// 러닝 경로를 지도에 표시하기 위한 `NMFPath` 오버레이를 생성하고 기본 스타일을 설정합니다.
    func makeRouteOverlay() -> NMFPath {
        let routeOverlay = NMFPath()
        
        routeOverlay.outlineWidth = 2
        routeOverlay.color = .red
        
        return routeOverlay
    }
}
