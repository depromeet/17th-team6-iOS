//
//  LocationServiceProtocol.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

enum LocationEvent {
    case didChangeAuth(CLAuthorizationStatus)
    case update(CLLocation)
    case error(Error)
}

protocol LocationServiceProtocol: AnyObject {
    var onEvent: ((LocationEvent) -> Void)? { get set }
    func checkAuthorization()
    func start()
    func stop()
}
