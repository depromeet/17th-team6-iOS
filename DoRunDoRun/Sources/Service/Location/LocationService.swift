//
//  LocationService.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol {
    var onEvent: ((LocationEvent) -> Void)?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 8 // 5~10m 권장
        
        // 인스턴스 생성 시점에 권한 설정
        checkAuthorization()
    }
    
    func checkAuthorization() {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            onEvent?(.didChangeAuth(status))
        }
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            let status = manager.authorizationStatus
            onEvent?(.didChangeAuth(status))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for cl in locations {
            // 정확도
            if cl.horizontalAccuracy >= 0, cl.horizontalAccuracy <= 40 { continue }
            onEvent?(.update(cl))
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        onEvent?(.error(error))
    }
}
