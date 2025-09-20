//
//  LocationService.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol {
    // 해당 객체를 만들 스레드에서 델리게이트 메서드가 실행된다.
    private let manager = CLLocationManager()
    private var continuation: AsyncThrowingStream<CLLocation, Error>.Continuation?
    private var isStreaming: Bool = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 8 // 5~10m 권장
    }
    
    func startTracking() throws(LocationServiceError) -> AsyncThrowingStream<CLLocation, Error> {
        if isStreaming { throw LocationServiceError.alreadyStreaming }
        
        try ensureAuthorized()
        
        return AsyncThrowingStream<CLLocation, Error> { [weak self] continuation in
            guard let self else { return }
            
            self.continuation = continuation
            self.isStreaming = true
            self.manager.startUpdatingLocation()
            
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                
                self.manager.stopUpdatingLocation()
                self.continuation = nil
                self.isStreaming = false
            }
        }
    }
    
    func stopTracking() {
        continuation?.finish()
    }
    
    private func ensureAuthorized() throws(LocationServiceError) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            throw LocationServiceError.notAuthorized
        default:
            throw LocationServiceError.notAuthorized
        }
    }
    
    deinit {
        stopTracking()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            if isStreaming {
                continuation?.finish(throwing: LocationServiceError.notAuthorized)
            }
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            // 정확도 필터: 0...40m 만 통과
            let acc = location.horizontalAccuracy
            guard acc >= 0, acc <= 40 else { continue }
            continuation?.yield(location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.finish(throwing: LocationServiceError.runtimeError(error))
    }
}
