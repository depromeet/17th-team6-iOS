//
//  FriendRunningStatusMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import Foundation

/// `FriendRunningStatus` 엔티티를 `FriendRunningStatusViewState`로 변환하는 Mapper입니다.
struct FriendRunningStatusViewStateMapper {
    static func map(from entity: FriendRunningStatus) -> FriendRunningStatusViewState {
        
        // MARK: - 최근 48시간 내 러닝 여부
        /// 최근 러닝 시간이 48시간 이내이면 러닝 중으로 간주합니다.
        let isRunning: Bool = {
            guard let latestRanAt = entity.latestRanAt else { return false }
            return Date().timeIntervalSince(latestRanAt) <= (48 * 3600)
        }()
        
        // MARK: - 깨우기 가능 여부
        let isCheerable: Bool = {
            let now = Date()

            // 러닝 기록 여부
            let hasRun = entity.latestRanAt != nil
            
            // 마지막 러닝 이후 경과한 시간(시간 단위)
            let hoursSinceRun = entity.latestRanAt.map { now.timeIntervalSince($0) / 3600 } ?? .infinity
            
            // 마지막 응원 이후 경과한 시간(시간 단위)
            let hoursSinceCheer = entity.latestCheeredAt.map { now.timeIntervalSince($0) / 3600 } ?? .infinity

            /*
             switch 패턴 설명
             ----------------------
             입력 튜플: (hasRun, hoursSinceRun, hoursSinceCheer)

             Truth Table 정리:
             1) 러닝 기록 없음 + 응원 24시간 지남 → 가능
             2) 러닝 기록 없음 + 응원 24시간 미만 → 불가능
             3) 러닝 기록 있음 + 마지막 러닝 48시간 미만 → 불가능
             4) 러닝 기록 있음 + 마지막 러닝 48시간 지남 + 응원 24시간 미만 → 불가능
             5) 러닝 기록 있음 + 마지막 러닝 48시간 지남 + 응원 24시간 지남 → 가능
             */

            switch (hasRun, hoursSinceRun, hoursSinceCheer) {

            // 1) 러닝 기록 없음 + (응원 이력이 없거나) 마지막 응원으로부터 24시간 지남 → 응원 가능
            case (false, _, let cheer) where cheer >= 24:
                return true

            // 2) 러닝 기록 없음 + 마지막 응원 24시간 미만 → 응원 불가능
            case (false, _, let cheer) where cheer < 24:
                return false

            // 3) 러닝 기록 있음 + 마지막 러닝 48시간 미만 → 응원 불가능
            case (true, let run, _) where run < 48:
                return false
                
            // 4) 러닝 기록 있음 + 마지막 러닝 48시간 지남 + 마지막 응원 24시간 미만 → 응원 불가능
            case (true, let run, let cheer) where run >= 48 && cheer < 24:
                return false

            // 5) 러닝 기록 있음 + 마지막 러닝 48시간 지남 + 마지막 응원 24시간 이상 → 응원 가능
            case (true, let run, let cheer) where run >= 48 && cheer >= 24:
                return true

            // 안전 장치 (실제로는 도달하지 않음)
            default:
                return false
            }
        }()
        
        // MARK: - 마지막 러닝 시각 텍스트 변환
        /// 최근 러닝 시각을 '방금 전', '몇 시간 전', '어제', '며칠 전' 등으로 표시합니다.
        let latestRanText: String? = {
            guard let date = entity.latestRanAt else { return nil }
            let interval = Date().timeIntervalSince(date)
            let minutes = Int(interval / 60)
            let hours = Int(interval / 3600)
            let days = Int(interval / 86400)
            let years = days / 365

            switch interval {
            case ..<60:
                return "방금 전"
            case ..<3600:
                return "\(minutes)분 전"
            case ..<86400:
                return "\(hours)시간 전"
            case ..<(86400 * 365):
                return "\(days)일 전"
            default:
                return "\(years)년 전"
            }
        }()
        
        // MARK: - 거리 텍스트 변환
        /// 거리(m)를 km 단위로 변환하여 "5.02 km"처럼 표시합니다.
        let distanceText: String? = {
            guard let distance = entity.distance else { return nil }
            return String(format: "%.2f km", distance / 1000)
        }()
        
        // MARK: - 최종 ViewState 생성
        return FriendRunningStatusViewState(
            renderId: UUID().uuidString,
            id: entity.id,
            name: entity.nickname,
            isMe: entity.isMe,
            profileImageURL: entity.profileImageURL,
            latestRanText: latestRanText,
            latestCheeredAt: entity.latestCheeredAt,
            isRunning: isRunning,
            isCheerable: isCheerable,
            distanceText: distanceText,
            latitude: entity.latitude,
            longitude: entity.longitude,
            address: entity.address
        )
    }
}
