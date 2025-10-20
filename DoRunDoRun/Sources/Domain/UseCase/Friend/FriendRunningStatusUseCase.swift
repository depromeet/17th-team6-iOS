//
//  FriendRunningStatusUseCase.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Foundation
import CoreLocation

protocol FriendRunningStatusUseCaseProtocol {
    func fetchStatuses() async throws -> [FriendRunningStatus]
    func resolveCity(for lat: Double, lng: Double) async -> String?
}

final class FriendRunningStatusUseCase: FriendRunningStatusUseCaseProtocol {
    private let repository: FriendRunningStatusRepository
    private let geocoder = CLGeocoder()
    
    init(repository: FriendRunningStatusRepository) {
        self.repository = repository
    }
    
    /// 서버로부터 친구 러닝 현황 조회
    func fetchStatuses() async throws -> [FriendRunningStatus] {
        try await repository.fetchRunningStatuses(page: 0, size: 20)
    }
    
    /// 위도, 경도를 기반으로 도시명 계산
    func resolveCity(for lat: Double, lng: Double) async -> String? {
        let location = CLLocation(latitude: lat, longitude: lng)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                var name = placemark.locality ?? placemark.administrativeArea ?? "알 수 없음"
                let suffixes = ["특별시", "광역시", "시", "도", "구"]
                for suffix in suffixes where name.hasSuffix(suffix) {
                    name = String(name.dropLast(suffix.count))
                    break
                }
                return name
            }
        } catch {
            print("❌ Reverse geocoding 실패:", error.localizedDescription)
        }
        return nil
    }
}

