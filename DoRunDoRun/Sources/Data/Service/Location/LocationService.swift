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
    /// 위치 권한 요청 (비동기)
    /// - Returns: 사용자가 권한을 허용했는지 여부
    func requestPermission() async -> Bool

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

    // 권한 요청을 위한 continuation
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    
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
    
    func requestPermission() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            // 권한 요청 후 delegate 응답 대기
            return await withCheckedContinuation { continuation in
                self.permissionContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        @unknown default:
            return false
        }
    }

    func startTracking() throws(LocationServiceError) -> AsyncThrowingStream<CLLocation, Error> {
        if isStreaming { throw LocationServiceError.alreadyStreaming }

        // 위치 권한 확인 (요청은 하지 않음)
        try checkAuthorizationStatus()

        return makeStreaming()
    }

    func stopTracking() {
        continuation?.finish()
    }

    /// 사용자 권한 확인 메서드 (요청은 하지 않음)
    func checkAuthorizationStatus() throws(LocationServiceError) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined, .denied, .restricted:
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

// MARK: - CLLocationManagerDelegate

extension LocationServiceImpl: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 권한 요청 응답 처리
        if permissionContinuation != nil {
            handlePermissionResponse(status: manager.authorizationStatus)
            return
        }

        // 스트리밍 중 권한 변경 감지
        handleStreamingAuthChange(status: manager.authorizationStatus)
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
    
    // MARK: Delegate Helper Methods
    
    /// 권한 요청에 대한 사용자 응답 처리
    private func handlePermissionResponse(status: CLAuthorizationStatus) {
        guard let permissionContinuation else { return }

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            permissionContinuation.resume(returning: true)
            self.permissionContinuation = nil
        case .denied, .restricted:
            permissionContinuation.resume(returning: false)
            self.permissionContinuation = nil
        case .notDetermined:
            // 아직 결정 안 됨, 계속 대기
            break
        @unknown default:
            permissionContinuation.resume(returning: false)
            self.permissionContinuation = nil
        }
    }

    /// 스트리밍 중 권한 변경 감지 (예: 설정에서 권한 취소)
    private func handleStreamingAuthChange(status: CLAuthorizationStatus) {
        guard isStreaming else { return }

        switch status {
        case .denied, .restricted:
            continuation?.finish(throwing: LocationServiceError.notAuthorized)
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            break
        }
    }
}
