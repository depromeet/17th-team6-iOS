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
            guard let lastRan = entity.latestRanAt else { return false }
            let now = Date()
            let hoursSinceRun = now.timeIntervalSince(lastRan) / 3600
            
            // 48시간 이상 러닝 안했는지 확인
            guard hoursSinceRun >= 48 else { return false }
            
            // 마지막 응원 후 24시간 이상 지났는지 확인
            if let lastCheer = entity.latestCheeredAt {
                let hoursSinceCheer = now.timeIntervalSince(lastCheer) / 3600
                return hoursSinceCheer >= 24
            } else {
                // 응원 이력이 없다면 즉시 가능
                return true
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
            
            switch interval {
            case ..<60:
                return "방금 전"
            case ..<3600:
                return "\(minutes)분 전"
            case ..<86400:
                return "\(hours)시간 전"
            case ..<(86400 * 2):
                return "어제"
            case ..<(86400 * 7):
                return "\(days)일 전"
            default:
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd HH:mm"
                return formatter.string(from: date)
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
