//
//  SquareRouteMap.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/31/25.
//

import SwiftUI

// MARK: - 정사각형 루트 지도
struct SquareRouteMap: View {
    let points: [RunningCoordinateViewState]
    let outerPadding: CGFloat

    @Binding var data: Data?
    
    var body: some View {
        RouteFitMapView(
            coordinates: points,
            cameraEdgeInsetAdjustment: outerPadding,
            data: $data
        )
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    StatefulPreview()
}

/// 지도 캡처 확인용 프리뷰
private struct StatefulPreview: View {
    @State private var snapshot: Data? = nil

    var body: some View {
        VStack(spacing: 12) {
            SquareRouteMap(
                points: RouteMocks.hanRiverLoop1km,
                outerPadding: 20,
                data: $snapshot
            )
            if let snapshot, let img = UIImage(data: snapshot) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Text("스냅샷 대기 중…").foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

enum RouteMocks {
    /// 성수 일대 짧은 경로 (약 수백 m)
    static let seongsuShort: [RunningCoordinateViewState] = [
        .init(latitude: 37.5465029, longitude: 127.0652630, paceSecPerKm: 300), // 5:00
        .init(latitude: 37.5469000, longitude: 127.0662000, paceSecPerKm: 320), // 5:20
        .init(latitude: 37.5473500, longitude: 127.0673500, paceSecPerKm: 340), // 5:40
        .init(latitude: 37.5479000, longitude: 127.0684000, paceSecPerKm: 360), // 6:00
        .init(latitude: 37.5483000, longitude: 127.0693000, paceSecPerKm: 380), // 6:20
        .init(latitude: 37.5487500, longitude: 127.0702500, paceSecPerKm: 400), // 6:40
        .init(latitude: 37.5491000, longitude: 127.0711000, paceSecPerKm: 420)  // 7:00
    ]

    /// 한강변을 가정한 1km 안팎 루프 경로
    static let hanRiverLoop1km: [RunningCoordinateViewState] = [
        .init(latitude: 37.5408000, longitude: 127.0700000, paceSecPerKm: 310),
        .init(latitude: 37.5415000, longitude: 127.0718000, paceSecPerKm: 320),
        .init(latitude: 37.5422000, longitude: 127.0735000, paceSecPerKm: 330),
        .init(latitude: 37.5430000, longitude: 127.0752000, paceSecPerKm: 340),
        .init(latitude: 37.5437000, longitude: 127.0767000, paceSecPerKm: 350),
        .init(latitude: 37.5443000, longitude: 127.0784000, paceSecPerKm: 360),
        .init(latitude: 37.5449000, longitude: 127.0800000, paceSecPerKm: 370),
        .init(latitude: 37.5452000, longitude: 127.0818000, paceSecPerKm: 380),
        .init(latitude: 37.5447000, longitude: 127.0830000, paceSecPerKm: 390),
        .init(latitude: 37.5440000, longitude: 127.0841000, paceSecPerKm: 400),
        .init(latitude: 37.5432000, longitude: 127.0850000, paceSecPerKm: 410),
        .init(latitude: 37.5424000, longitude: 127.0857000, paceSecPerKm: 420),
        .init(latitude: 37.5416000, longitude: 127.0860000, paceSecPerKm: 430),
        .init(latitude: 37.5409000, longitude: 127.0854000, paceSecPerKm: 440),
        .init(latitude: 37.5403000, longitude: 127.0841000, paceSecPerKm: 450),
        .init(latitude: 37.5401000, longitude: 127.0824000, paceSecPerKm: 460),
        .init(latitude: 37.5403000, longitude: 127.0807000, paceSecPerKm: 470),
        .init(latitude: 37.5405000, longitude: 127.0790000, paceSecPerKm: 480),
        .init(latitude: 37.5407000, longitude: 127.0773000, paceSecPerKm: 490),
        .init(latitude: 37.5408000, longitude: 127.0756000, paceSecPerKm: 500),
        .init(latitude: 37.5408000, longitude: 127.0740000, paceSecPerKm: 510),
        .init(latitude: 37.5408000, longitude: 127.0723000, paceSecPerKm: 520),
        .init(latitude: 37.5408000, longitude: 127.0708000, paceSecPerKm: 530),
        .init(latitude: 37.5408000, longitude: 127.0700000, paceSecPerKm: 540)
    ]
}
