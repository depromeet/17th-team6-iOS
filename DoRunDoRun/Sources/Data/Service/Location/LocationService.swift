//
//  LocationService.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/21/25.
//

import CoreLocation

enum LocationServiceError: Error {
    case notAuthorized
    case alreadyStreaming
    case runtimeError(Error)
}

/// 사용자 위치 기반 데이터 수집 관련 인터페이스
protocol LocationService: AnyObject {
    /// CoreLocation 업데이트 스트림을 시작하고 비동기 시퀀스를 반환
    func startTracking() throws(LocationServiceError) -> AsyncThrowingStream<CLLocation, Error>
    func stopTracking()
}

/// LocationService 인터페이스 구현체
final class LocationServiceImpl: NSObject, LocationService {
    // 해당 객체를 만들 스레드에서 델리게이트 메서드가 실행된다.
    private let manager = CLLocationManager()
    
    private var continuation: AsyncThrowingStream<CLLocation, Error>.Continuation?
    private var isStreaming: Bool = false
    
    override init() {
        super.init()

        manager.delegate = self
        manager.activityType = .fitness

        // 백그라운드 위치 추적 설정
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true // 사용자 투명성 제공
        manager.pausesLocationUpdatesAutomatically = false // 연속 추적
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
    }
    
    func startTracking() throws(LocationServiceError) -> AsyncThrowingStream<CLLocation, Error> {
        if isStreaming { throw LocationServiceError.alreadyStreaming }
        
        // 위치 권한 확인
        try checkAuthorizationStatus()
        
        return makeStreaming()
    }
    
    func stopTracking() {
        continuation?.finish()
    }
    
    /// 사용자 권한 요청 메서드
    func checkAuthorizationStatus() throws(LocationServiceError) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .denied, .restricted:
            throw LocationServiceError.notAuthorized
        @unknown default:
            break
        }
    }
    
    // MARK: - Private Helpers
    /// 실제 AsyncThrowingStream 구성 및 CLLocationManager 업데이트 시작
    private func makeStreaming() -> AsyncThrowingStream<CLLocation, Error> {
        AsyncThrowingStream<CLLocation, Error> { [weak self] continuation in
            guard let self else { return }
            
            self.continuation = continuation
            self.isStreaming = true
            self.manager.startUpdatingLocation()
            
            continuation.onTermination = { [weak self] _ in
                self?.cleanupStreaming()
            }
        }
    }
    
    private func cleanupStreaming() {
        self.manager.stopUpdatingLocation()
        self.continuation = nil
        self.isStreaming = false
    }
    
    deinit {
        stopTracking()
    }
}

extension LocationServiceImpl: CLLocationManagerDelegate {
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
            let hAcc = location.horizontalAccuracy
            let vAcc = location.verticalAccuracy
                        
            guard hAcc >= 0, hAcc <= 40, vAcc >= 0 else { continue }
            continuation?.yield(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown, .headingFailure:
                return
            case .denied: // 사용자 위치 권한 거부
                continuation?.finish(throwing: LocationServiceError.notAuthorized)
            default:
                continuation?.finish(throwing: LocationServiceError.runtimeError(clError))
            }
        }
        continuation?.finish(throwing: LocationServiceError.runtimeError(error))
    }
}
