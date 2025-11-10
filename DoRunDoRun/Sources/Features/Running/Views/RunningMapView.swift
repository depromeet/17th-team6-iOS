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

    /// GPS 버튼 Following 모드 (Ready, Active 단계 모두 사용)
    var isFollowingLocation: Bool = false
    var onMapGestureDetected: (() -> Void)? = nil

    /// 사용자 위치 (Ready 단계에서 사용)
    var userLocation: UserLocationViewState? = nil

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

        // Delegate 설정 (제스처 감지용)
        context.coordinator.onMapGestureDetected = onMapGestureDetected
        mapView.mapView.addCameraDelegate(delegate: context.coordinator)

        // 경로 세그먼트는 Active 단계에서 생성됨

        return mapView
    }

    // MARK: - UIView 갱신
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // Phase 변경 감지 및 플래그 리셋
        if context.coordinator.lastPhase != phase {
            context.coordinator.lastPhase = phase

            // Ready phase로 진입할 때마다 플래그 리셋
            if phase == .ready {
                context.coordinator.didCenterUserLocationOnReady = false
                context.coordinator.didSetContentInset = false
            }

            // Active phase로 진입할 때마다 플래그 리셋 및 contentInset 초기화
            if phase == .active {
                context.coordinator.didCenterInitialCamera = false
                uiView.mapView.contentInset = .zero
            }
        }

        switch phase {
        case .ready:
            updateForReady(uiView, context: context)
        case .countdown:
            return
        case .active:
            updateForActive(uiView, context: context)
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        var markers: [NMFMarker] = []
        var currentFriendID: Int?
        var routeSegments: [NMFPath] = []     // 구간별 경로 세그먼트 (색상별로 분리됨)
        var didCenterInitialCamera = false    // Active 최초 1회 카메라 센터링 여부
        var didCenterUserLocationOnReady = false  // Ready 최초 1회 사용자 위치 센터링 여부
        var lastPhase: RunningPhase?          // Phase 변경 감지용
        var didSetContentInset = false        // Ready contentInset 설정 여부

        var onMapGestureDetected: (() -> Void)?
        private var isUserGesture = false

        // 카메라가 움직이기 시작할 때
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            // reason: -1 = 제스처, 0+ = 프로그래밍
            if reason == -1 {
                isUserGesture = true
            }
        }

        // 카메라 움직임이 끝났을 때
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            if isUserGesture {
                onMapGestureDetected?()
                isUserGesture = false
            }
        }
    }
}

// MARK: - Ready Phase
private extension RunningMapView {
    /// Ready 단계에서 지도 상태를 갱신합니다.
    func updateForReady(_ uiView: NMFNaverMapView, context: Context) {
        // contentInset 설정 (Ready phase 진입 시 1회만)
        if !context.coordinator.didSetContentInset {
            // collapsed state 만큼 올리기
            uiView.mapView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 180,
                right: 0
            )
            context.coordinator.didSetContentInset = true
        }

        // 1. 초기 진입 시 사용자 위치로 카메라 센터링 (1회만)
        if !context.coordinator.didCenterUserLocationOnReady,
            let userLoc = userLocation {
            centerCameraToUserLocation(userLoc, in: uiView.mapView)
            context.coordinator.didCenterUserLocationOnReady = true

            return
        }

        // 2. 친구 포커싱이 활성화된 경우 친구 마커 표시 및 카메라 이동
        if focusedFriendID != nil {
            updateFocusedFriendMarker(on: uiView.mapView, context: context)
        } else {
            // 친구 포커싱 해제 시 마커 제거
            clearFriendMarkers(context: context)

            // GPS Following ON이고 사용자 위치가 있으면 카메라 추적
            if isFollowingLocation,
                let userLoc = userLocation {
                centerCameraToUserLocation(userLoc, in: uiView.mapView)
            }
        }
    }

    /// 사용자 위치로 카메라 이동 (contentInset으로 오프셋 자동 적용)
    func centerCameraToUserLocation(_ location: UserLocationViewState, in mapView: NMFMapView) {
        let latLng = NMGLatLng(lat: location.latitude, lng: location.longitude)
        let update = NMFCameraUpdate(position: NMFCameraPosition(latLng, zoom: CameraZoomLevel.default))
        update.animation = .easeIn
        mapView.moveCamera(update)
    }

    /// 포커스된 친구의 마커만 표시
    func updateFocusedFriendMarker(on mapView: NMFMapView, context: Context) {
        // 이미 같은 친구라면 다시 그리지 않음
        if context.coordinator.currentFriendID == focusedFriendID {
            return
        }

        // 기존 마커 제거
        clearFriendMarkers(context: context)

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

    /// 친구 마커 제거
    func clearFriendMarkers(context: Context) {
        context.coordinator.markers.forEach { $0.mapView = nil }
        context.coordinator.markers.removeAll()
        context.coordinator.currentFriendID = nil
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
        let update = NMFCameraUpdate(
            position: NMFCameraPosition(latLng, zoom: CameraZoomLevel.focusedFriend)
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

        // Following ON일 때 자동으로 내 위치 추적
        if isFollowingLocation, let lastCoordinate = runningCoordinates.last {
            centerCamera(on: lastCoordinate, in: uiView.mapView)
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
    
    /// runningCoordinates를 이용해 경로를 업데이트한다. (페이스 기반 색상 적용)
    func updateRunningRoute(on mapView: NMFMapView, context: Context) {
        // 좌표가 2개 미만이면 경로를 그릴 수 없으므로 제거
        guard runningCoordinates.count >= 2 else {
            clearRouteSegments(context: context)
            return
        }

        // 기존 세그먼트 제거
        clearRouteSegments(context: context)

        // 구간별 NMFPath 생성 (원본 좌표 사용)
        for i in 0..<(runningCoordinates.count - 1) {
            let start = runningCoordinates[i]
            let end = runningCoordinates[i + 1]

            // 현재 구간의 페이스 색상 결정
            let paceColor = PaceColorMapper.color(forPaceSecPerKm: start.paceSecPerKm)

            // 구간 경로 생성
            let segment = NMFPath()
            let startLatLng = NMGLatLng(lat: start.latitude, lng: start.longitude)
            let endLatLng = NMGLatLng(lat: end.latitude, lng: end.longitude)
            let lineString = NMGLineString(points: [startLatLng, endLatLng] as [AnyObject])

            segment.path = lineString
            segment.color = paceColor
            segment.width = 8
            segment.outlineColor = .clear
            segment.mapView = mapView

            context.coordinator.routeSegments.append(segment)
        }
    }

    /// 기존 경로 세그먼트를 모두 제거합니다.
    func clearRouteSegments(context: Context) {
        context.coordinator.routeSegments.forEach { $0.mapView = nil }
        context.coordinator.routeSegments.removeAll()
    }
}
