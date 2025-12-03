//
//  RunningMapView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

import NMapsMap

/// 지도상의 좌표를 나타내는 타입을 위한 프로토콜
protocol CoordinateRepresentable {
    var latitude: Double { get }
    var longitude: Double { get }
}

// MARK: - CoordinateRepresentable Conformance
extension UserLocationViewState: CoordinateRepresentable {}
extension RunningCoordinateViewState: CoordinateRepresentable {}

/// 러닝 전, 러닝 중 화면에서 보여질 NaverMap
struct RunningMapView: UIViewRepresentable {
    
    enum CameraZoomLevel {
        static let min: Double = 6
        static let max: Double = 18
        static let `default`: Double = 16
        static let focusedFriend: Double = 14
    }

    enum MapConstants {
        static let readyPhaseBottomInset: CGFloat = 180
        static let userGestureReasonCode = -1
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

        // 내 위치 마커 표시
        mapView.mapView.locationOverlay.hidden = false

        // Delegate 설정 (제스처 감지용)
        context.coordinator.onMapGestureDetected = onMapGestureDetected
        mapView.mapView.addCameraDelegate(delegate: context.coordinator)

        // 경로 세그먼트는 Active 단계에서 생성됨

        return mapView
    }

    // MARK: - UIView 갱신
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // Phase 전환 감지 및 초기 설정 (1회만)
        if context.coordinator.lastPhase != phase {
            context.coordinator.lastPhase = phase

            switch phase {
            case .ready:
                setupForReady(uiView, context: context)
            case .active:
                setupForActive(uiView, context: context)
            case .countdown:
                break
            }
        }

        // 지속적인 업데이트 (매 렌더링마다)
        switch phase {
        case .ready:
            updateForReady(uiView, context: context)
        case .active:
            updateForActive(uiView, context: context)
        case .countdown:
            return
        }
    }

    // MARK: - Friend Marker Manager
    class FriendMarkerManager {
        private var markers: [NMFMarker] = []
        private var currentFriendID: Int?

        /// 현재 포커스된 ID와 동일한지 확인하여 업데이트 필요 여부 반환
        func needsUpdate(for focusedID: Int?) -> Bool {
            return currentFriendID != focusedID
        }

        /// 포커스된 친구의 마커를 업데이트
        func update(
            friends: [FriendRunningStatusViewState],
            focusedID: Int?,
            on mapView: NMFMapView
        ) {
            guard needsUpdate(for: focusedID) else { return }

            clear()

            guard
                let focusedID = focusedID,
                let friend = friends.first(where: { $0.id == focusedID }),
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
                markers.append(marker)
            }

            currentFriendID = focusedID
        }

        /// 모든 마커 제거
        func clear() {
            markers.forEach { $0.mapView = nil }
            markers.removeAll()
            currentFriendID = nil
        }
    }

    // MARK: - Route Segment Manager
    class RouteSegmentManager {
        private var segments: [NMFPath] = []

        /// 경로 좌표로부터 세그먼트를 업데이트
        func update(
            coordinates: [RunningCoordinateViewState],
            on mapView: NMFMapView
        ) {
            // 좌표가 2개 미만이면 경로를 그릴 수 없으므로 제거
            guard coordinates.count >= 2 else {
                clear()
                return
            }

            // 기존 세그먼트 제거
            clear()

            // 구간별 NMFPath 생성 (원본 좌표 사용)
            for i in 0..<(coordinates.count - 1) {
                let start = coordinates[i]
                let end = coordinates[i + 1]

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

                segments.append(segment)
            }
        }

        /// 모든 세그먼트 제거
        func clear() {
            segments.forEach { $0.mapView = nil }
            segments.removeAll()
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        let friendMarkerManager = FriendMarkerManager()
        let routeSegmentManager = RouteSegmentManager()
        
        var lastPhase: RunningPhase?

        var onMapGestureDetected: (() -> Void)?
        private var isUserGesture = false

        // 카메라가 움직이기 시작할 때
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            // reason: -1 = 제스처, 0+ = 프로그래밍
            if reason == MapConstants.userGestureReasonCode {
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
    /// Ready phase 진입 시 초기 설정 (1회만)
    func setupForReady(_ uiView: NMFNaverMapView, context: Context) {
        // ContentInset 설정 (collapsed state 만큼)
        uiView.mapView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: MapConstants.readyPhaseBottomInset,
            right: 0
        )

        // 사용자 위치로 초기 카메라 센터링
        if let userLoc = userLocation {
            centerCamera(on: userLoc, in: uiView.mapView)
        }

        // Active에서 남은 경로 제거
        context.coordinator.routeSegmentManager.clear()
    }

    /// Ready 단계에서 지도 상태를 갱신합니다 (매 렌더링마다)
    func updateForReady(_ uiView: NMFNaverMapView, context: Context) {
        // 내 위치 마커 업데이트
        if let userLoc = userLocation {
            let location = NMGLatLng(lat: userLoc.latitude, lng: userLoc.longitude)
            uiView.mapView.locationOverlay.location = location
        }

        // 친구 마커 업데이트
        context.coordinator.friendMarkerManager.update(
            friends: statuses,
            focusedID: focusedFriendID,
            on: uiView.mapView
        )

        // 카메라 업데이트
        if focusedFriendID != nil {
            // 포커스된 친구로 카메라 이동
            moveCamera(to: focusedFriendID, in: uiView.mapView)
        } else {
            // GPS Following 카메라 추적
            updateCameraForFollowing(
                isFollowing: isFollowingLocation,
                location: userLocation,
                in: uiView.mapView
            )
        }
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
    /// Active phase 진입 시 초기 설정 (1회만)
    func setupForActive(_ uiView: NMFNaverMapView, context: Context) {
        // ContentInset 초기화
        uiView.mapView.contentInset = .zero

        // Ready에서 남은 친구 마커 제거
        context.coordinator.friendMarkerManager.clear()
    }

    /// Active 단계에서 지도 상태를 갱신합니다 (매 렌더링마다)
    func updateForActive(_ uiView: NMFNaverMapView, context: Context) {
        // 내 위치 마커 업데이트
        if let lastCoord = runningCoordinates.last {
            let location = NMGLatLng(lat: lastCoord.latitude, lng: lastCoord.longitude)
            uiView.mapView.locationOverlay.location = location
        }

        // GPS Following 카메라 추적
        updateCameraForFollowing(
            isFollowing: isFollowingLocation,
            location: runningCoordinates.last,
            in: uiView.mapView
        )

        // 경로 세그먼트 업데이트
        context.coordinator.routeSegmentManager.update(
            coordinates: runningCoordinates,
            on: uiView.mapView
        )
    }

    /// 주어진 좌표를 기준으로 카메라를 가운데로 이동
    func centerCamera(
        on coordinate: CoordinateRepresentable,
        in mapView: NMFMapView,
        zoom: Double = CameraZoomLevel.default
    ) {
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let update = NMFCameraUpdate(position: NMFCameraPosition(latLng, zoom: zoom))
        update.animation = .easeIn
        mapView.moveCamera(update)
    }

    /// GPS Following 모드일 때 카메라 업데이트 (Ready/Active 공통)
    func updateCameraForFollowing(
        isFollowing: Bool,
        location: CoordinateRepresentable?,
        in mapView: NMFMapView,
        zoom: Double = CameraZoomLevel.default
    ) {
        guard isFollowing, let location = location else { return }
        centerCamera(on: location, in: mapView, zoom: zoom)
    }
}
