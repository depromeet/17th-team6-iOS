//
//  LocationPermissionRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/17/25.
//

final class LocationPermissionRepositoryImpl: LocationPermissionRepository {
    private let locationService: LocationService

    init(locationService: LocationService = LocationServiceImpl()) {
        self.locationService = locationService
    }

    func requestPermission() async -> Bool {
        return await locationService.requestPermission()
    }
}
