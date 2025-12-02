//
//  UserLocationRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/10/25.
//

import CoreLocation

final actor UserLocationRepositoryImpl: UserLocationRepository {
    private let locationService: LocationService

    init(locationService: LocationService = LocationServiceImpl()) {
        self.locationService = locationService
    }

    func startTracking() async throws -> AsyncThrowingStream<RunningCoordinate, Error> {
        let locationStream = try locationService.startTracking()

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await location in locationStream {
                        let coordinate = RunningCoordinate(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                        continuation.yield(coordinate)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func stopTracking() async {
        locationService.stopTracking()
    }

    func hasLocationPermission() async -> Bool {
        locationService.hasLocationPermission()
    }
}
