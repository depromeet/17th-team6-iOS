//
//  LocationPermissionRepository.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/17/25.
//

/// 위치 권한 관련 Repository
protocol LocationPermissionRepository {
    /// 위치 권한 요청
    /// - Returns: 사용자가 권한을 허용했는지 여부
    func requestPermission() async -> Bool
}
