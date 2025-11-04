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
        
        // 경로 초기화
        let path = NMFPath()
        applyPathStyle(path)
        path.mapView = map
        context.coordinator.path = path

        return view
    }

    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        guard coordinates.count >= 2 else { return }
        
        // 1️⃣ 경로 적용
        let latlngs = makeLatLngs()
        setPath(latlngs, on: uiView.mapView, context: context)

        // 2️⃣ 전체 구간이 보이도록 카메라 맞춤
        let bounds = makeBounds(from: latlngs)
        fitCamera(to: bounds, in: uiView.mapView)
        
        scheduleSnapshot(on: uiView)
    }

    // MARK: - 스타일
    private func applyPathStyle(_ path: NMFPath) {
        path.color = .red
        path.width = 8
        path.outlineColor = .clear
    }

    // MARK: - Helper Methods
    private func makeLatLngs() -> [AnyObject] {
        coordinates.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
    }

    private func setPath(_ latlngs: [AnyObject], on mapView: NMFMapView, context: Context) {
        context.coordinator.path?.path = NMGLineString(points: latlngs)
        context.coordinator.path?.mapView = mapView
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
        var path: NMFPath?
    }
}
