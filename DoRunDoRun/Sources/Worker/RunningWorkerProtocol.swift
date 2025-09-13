//
//  RunningWorkerProtocol.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

protocol RunningWorkerProtocol: AnyObject {
    // Outputs
    var onDidChangeAuth: ((CLAuthorizationStatus) -> Void)? { get set }
    var onDidUpdateRoute: ((RunningPoint) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }

    // Controls
    func checkAuthorization()
    func startRouteTracking()
    func finishRouteTracking()
}
