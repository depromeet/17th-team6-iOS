//
//  RunningWorker.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/13/25.
//

import CoreLocation

final class RunningWorker: RunningWorkerProtocol {
    private let repository: RunningRepositoryProtocol

    // MARK: - Outputs
    var onDidChangeAuth: ((CLAuthorizationStatus) -> Void)?
    var onDidUpdateRoute: ((RunningPoint) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - Init
    init(repository: RunningRepositoryProtocol) {
        self.repository = repository

        // Repository 이벤트를 구독하고, 워커 콜백으로 브릿지
        self.repository.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .didChangeAuth(let status):
                self.onDidChangeAuth?(status)
            case .didUpdateRoute(let point):
                self.onDidUpdateRoute?(point)
            case .error(let error):
                self.onError?(error)
            }
        }
    }

    // MARK: - Controls
    func checkAuthorization() {
        repository.checkAuthorization()
    }

    func startRouteTracking() {
        repository.startRouteTracking()
    }

    func finishRouteTracking() {
        repository.finishRouteTracking()
    }
}
