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

enum LocationAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
}

/// 사용자 위치 기반 데이터 수집 관련 인터페이스
protocol LocationService: AnyObject {
    /// CoreLocation 업데이트 스트림을 시작하고 비동기 시퀀스를 반환
    func startTracking() throws(LocationServiceError) -> AsyncThrowingStream<CLLocation, Error>
    func stopTracking()
    /// 현재 위치 권한 상태 확인
    func hasLocationPermission() -> Bool
    /// 현재 위치 권한 상태 반환 (notDetermined 포함)
    func getAuthorizationStatus() -> LocationAuthorizationStatus
    /// 위치 권한 요청 후 사용자 응답 대기
    func requestLocationPermission() async -> Bool
}

/// LocationService 인터페이스 구현체
final class LocationServiceImpl: NSObject, LocationService {
    // 해당 객체를 만들 스레드에서 델리게이트 메서드가 실행된다.
    private let manager = CLLocationManager()

    private var continuation: AsyncThrowingStream<CLLocation, Error>.Continuation?
    private var isStreaming: Bool = false

    /// 권한 요청 후 응답을 기다리기 위한 continuation
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?
    
    override init() {
        super.init()

        manager.delegate = self
        manager.activityType = .fitness

        // 백그라운드 위치 추적 설정
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true // 사용자 투명성 제공
        manager.pausesLocationUpdatesAutomatically = false // 연속 추적
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5 // 5~10m 권장
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

    func hasLocationPermission() -> Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    func getAuthorizationStatus() -> LocationAuthorizationStatus {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }

    func requestLocationPermission() async -> Bool {
        // 이미 결정된 경우 바로 반환
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            break
        @unknown default:
            return false
        }

        // 권한 요청 후 응답 대기
        return await withCheckedContinuation { continuation in
            self.authorizationContinuation = continuation
            self.manager.requestWhenInUseAuthorization()
        }
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
        // 권한 요청 대기 중인 continuation이 있으면 결과 전달
        if let authContinuation = authorizationContinuation {
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                authorizationContinuation = nil
                authContinuation.resume(returning: true)
                return
            case .denied, .restricted:
                authorizationContinuation = nil
                authContinuation.resume(returning: false)
                return
            case .notDetermined:
                // 아직 결정되지 않음 - 대기 유지
                break
            @unknown default:
                authorizationContinuation = nil
                authContinuation.resume(returning: false)
                return
            }
        }

        switch manager.authorizationStatus {
        case .denied, .restricted:
            if isStreaming {
                continuation?.finish(throwing: LocationServiceError.notAuthorized)
            }
        case .authorizedAlways, .authorizedWhenInUse:
            // 권한이 허용되었고 스트리밍 중이라면 위치 업데이트 시작
            if isStreaming {
                manager.startUpdatingLocation()
            }
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
