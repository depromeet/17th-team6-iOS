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
        
        // 경로 오버레이 초기 생성 + 스타일
        context.coordinator.routeOverlay = makeRouteOverlay()
        
        return mapView
    }

    // MARK: - UIView 갱신
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        switch phase {
        case .ready:
            // 포커스된 친구만 마커 표시
            updateFocusedFriendMarker(on: uiView.mapView, context: context)
        case .countdown:
            return
        case .active:
            updateForActive(uiView, context: context)
        }
    }

    // MARK: - Coordinator
    class Coordinator {
        var markers: [NMFMarker] = []
        var currentFriendID: Int?
        var routeOverlay: NMFPath?            // 경로 오버레이 보관
        var didCenterInitialCamera = false    // Active 최초 1회 카메라 센터링 여부
    }
}

// MARK: - Private Helpers
private extension RunningMapView {
    /// 포커스된 친구의 마커만 표시
    func updateFocusedFriendMarker(on mapView: NMFMapView, context: Context) {
        // 이미 같은 친구라면 다시 그리지 않음
        if context.coordinator.currentFriendID == focusedFriendID {
            return
        }
        
        // 기존 마커 제거
        context.coordinator.markers.forEach { $0.mapView = nil }
        context.coordinator.markers.removeAll()
        
        guard
            let focusedID = focusedFriendID,
            let friend = statuses.first(where: { $0.id == focusedID }),
            let lat = friend.latitude,
            let lng = friend.longitude
        else { return }
        
        let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
        
        Task { @MainActor in
            let customView = FriendMarkerView(
                name: friend.name,
                profileImageURL: friend.profileImageURL,
                isRunning: friend.isRunning,
                isFocused: true
            )
            marker.iconImage = NMFOverlayImage(image: customView.snapshot())
            marker.mapView = mapView
            context.coordinator.markers.append(marker)
        }

        // 카메라 이동
        moveCamera(to: focusedID, in: mapView)
        
        context.coordinator.currentFriendID = focusedID
    }
    
    /// 포커스된 친구 위치로 카메라 이동
    func moveCamera(to focusedID: Int?, in mapView: NMFMapView) {
        guard
            let focusedID,
            let friend = statuses.first(where: { $0.id == focusedID }),
            let lat = friend.latitude,
            let lng = friend.longitude
        else { return }

        let latLng = NMGLatLng(lat: lat, lng: lng)
        let projection = mapView.projection
        
        // 친구 위로 살짝 띄워서 이동
        let screenPoint = projection.point(from: latLng)
        let adjustedPoint = CGPoint(x: screenPoint.x, y: screenPoint.y + 150)
        let adjustedLatLng = projection.latlng(from: adjustedPoint)

        let update = NMFCameraUpdate(
            position: NMFCameraPosition(adjustedLatLng, zoom: CameraZoomLevel.focusedFriend)
        )
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
        routeOverlay.color = .red
        routeOverlay.width = 8
        
        routeOverlay.outlineColor = .clear
        
        return routeOverlay
    }
}
