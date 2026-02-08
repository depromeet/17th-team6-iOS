//
//  RouteFitMapView.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/31/25.
//


import SwiftUI

import NMapsMap

// MARK: - 지도 컴포넌트
struct RouteFitMapView: UIViewRepresentable {
    @Binding var data: Data?
    
    /// 경로로 이어질 좌표 배열 (2개 이상이면 경로+fit)
    var coordinates: [RunningCoordinateViewState]
    
    /// 경계 여백 (지도의 네 면 padding)
    var edgeInset: CGFloat = 30
    
    /// 카메라 fit 패딩에 추가로 더해지는 외부 패딩 보정값
    /// 부모 뷰에서 추가된 외부 패딩 때문에 경로가 잘리는 현상을 방지하기 위해 사용됨
    let cameraEdgeInsetAdjustment: CGFloat
    
    var image: UIImage?

    init(
        coordinates: [RunningCoordinateViewState],
        cameraEdgeInsetAdjustment: CGFloat,
        data: Binding<Data?>
    ) {
        self.coordinates = coordinates
        
        // 외부에서 추가된 패딩으로 인해 Route Inset 추가
        self.cameraEdgeInsetAdjustment =  edgeInset + cameraEdgeInsetAdjustment
        self._data = data
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView(frame: .zero)
        
        view.showScaleBar = false
        view.showZoomControls = false
        view.showLocationButton = false
        
        let map = view.mapView
        map.isUserInteractionEnabled = false
        map.logoInteractionEnabled = false

        return view
    }

    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        guard coordinates.count >= 2 else { return }

        // 1️⃣ 구간별 경로 적용 (페이스 기반 색상)
        createPathSegments(on: uiView.mapView, context: context)

        // 2️⃣ 전체 구간이 보이도록 카메라 맞춤
        let latlngs = makeLatLngs()
        let bounds = makeBounds(from: latlngs)
        fitCamera(to: bounds, in: uiView.mapView)

        scheduleSnapshot(on: uiView)
    }

    // MARK: - Helper Methods
    private func makeLatLngs() -> [AnyObject] {
        coordinates.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
    }

    /// 구간별 경로 세그먼트를 생성하고 페이스 기반 색상을 적용합니다.
    private func createPathSegments(on mapView: NMFMapView, context: Context) {
        // 기존 세그먼트 제거
        clearPathSegments(context: context)

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

            context.coordinator.pathSegments.append(segment)
        }
    }

    /// 기존 경로 세그먼트를 모두 제거합니다.
    private func clearPathSegments(context: Context) {
        context.coordinator.pathSegments.forEach { $0.mapView = nil }
        context.coordinator.pathSegments.removeAll()
    }

    private func makeBounds(from latlngs: [AnyObject]) -> NMGLatLngBounds {
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLng = Double.greatestFiniteMagnitude
        var maxLng = -Double.greatestFiniteMagnitude
        
        for any in latlngs {
            if let p = any as? NMGLatLng {
                minLat = min(minLat, p.lat)
                maxLat = max(maxLat, p.lat)
                minLng = min(minLng, p.lng)
                maxLng = max(maxLng, p.lng)
            }
        }
        return NMGLatLngBounds(
            southWest: NMGLatLng(lat: minLat, lng: minLng),
            northEast: NMGLatLng(lat: maxLat, lng: maxLng)
        )
    }

    /// 짧은 경로에서 지도가 과도하게 확대되지 않도록 제한하는 최대 줌 레벨
    private static let maxZoomLevel: Double = 17

    private func fitCamera(to bounds: NMGLatLngBounds, in mapView: NMFMapView) {
        let inset = UIEdgeInsets(
            top: cameraEdgeInsetAdjustment,
            left: cameraEdgeInsetAdjustment,
            bottom: cameraEdgeInsetAdjustment,
            right: cameraEdgeInsetAdjustment
        )
        let update = NMFCameraUpdate(fit: bounds, paddingInsets: inset)
        update.animation = .none
        mapView.moveCamera(update)

        // 짧은 경로일 때 과도한 확대 방지
        if mapView.zoomLevel > Self.maxZoomLevel {
            let zoomUpdate = NMFCameraUpdate(zoomTo: Self.maxZoomLevel)
            zoomUpdate.animation = .none
            mapView.moveCamera(zoomUpdate)
        }
    }
    
    // MARK: - Make Snapshot Data
    /// 카메라/타일이 안정화된 뒤 스냅샷을 생성하여 바인딩에 기록합니다.
    private func scheduleSnapshot(on uiView: NMFNaverMapView) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard let image = snapshotImage(uiView) else {
                print("⚠️ 지도 캡처 실패")
                return
            }
            
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                print("⚠️ 이미지 데이터 생성 실패")
                return
            }
            
            self.data = imageData
        }
    }
    
    private func snapshotImage(_ uiView: NMFNaverMapView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: uiView.bounds.size)
        return renderer.image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }
    }


    // MARK: - Coordinator
    class Coordinator {
        var pathSegments: [NMFPath] = []  // 구간별 경로 세그먼트 (페이스 기반 색상)
    }
}
