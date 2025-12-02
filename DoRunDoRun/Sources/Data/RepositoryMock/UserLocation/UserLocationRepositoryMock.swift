//
//  UserLocationRepositoryMock.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/10/25.
//

import Foundation

final actor UserLocationRepositoryMock: UserLocationRepository {

    func startTracking() async throws -> AsyncThrowingStream<RunningCoordinate, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                // Mock 데이터: 서울 시청 근처 좌표
                let mockCoordinates: [RunningCoordinate] = [
                    RunningCoordinate(latitude: 37.5665, longitude: 126.9780),
                    RunningCoordinate(latitude: 37.5666, longitude: 126.9781),
                    RunningCoordinate(latitude: 37.5667, longitude: 126.9782),
                    RunningCoordinate(latitude: 37.5668, longitude: 126.9783)
                ]

                for coordinate in mockCoordinates {
                    try? await Task.sleep(for: .seconds(1)) // 1초마다 위치 업데이트
                    continuation.yield(coordinate)
                }

                continuation.finish()
            }
        }
    }

    func stopTracking() async {
        // Mock: 아무 동작 안함
    }

    func hasLocationPermission() async -> Bool {
        // Mock: 항상 권한 있음
        return true
    }
}
