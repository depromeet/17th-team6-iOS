//
//  RunningReadyMapView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/15/25.
//

import SwiftUI
import NMapsMap

struct RunningReadyMapView: UIViewRepresentable {
    var latitude: Double
    var longitude: Double
    var zoom: Double = 15.0

    func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView(frame: .zero)
        mapView.mapView.positionMode = .direction
        mapView.showZoomControls = false

        // 외부에서 전달받은 좌표로 카메라 설정
        let camera = NMFCameraPosition(NMGLatLng(lat: latitude, lng: longitude), zoom: zoom)
        mapView.mapView.moveCamera(NMFCameraUpdate(position: camera))
        return mapView
    }

    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {}
}

#Preview {
    RunningReadyMapView(latitude: 37.5665, longitude: 126.9780)
}
