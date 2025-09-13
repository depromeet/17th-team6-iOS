//
//  RunningRepository.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

enum RunningEvent {
    case didChangeAuth(CLAuthorizationStatus)
    case didUpdateRoute(RunningPoint)
    case error(Error)
}

final class RunningRepository: RunningRepositoryProtocol {
    private let locationService: LocationServiceProtocol
    
    var onEvent: ((RunningEvent) -> Void)?
    
    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
        
        // LocationService 이벤트를 수신하여 도메인 이벤트로 브릿지
        self.locationService.onEvent = { [weak self] event in
            switch event {
            case .didChangeAuth(let status):
                self?.onEvent?(.didChangeAuth(status))
                
            case .update(let clLocation):
                let point = clLocation.toDomain()
                self?.onEvent?(.didUpdateRoute(point))
                
            case .error(let error):
                self?.onEvent?(.error(error))
            }
        }
    }
    
    // MARK: - Controls
    func checkAuthorization() { locationService.checkAuthorization() }
    func startRouteTracking() { locationService.startUpdating() }
    func finishRouteTracking() { locationService.stopUpdating() }
}
