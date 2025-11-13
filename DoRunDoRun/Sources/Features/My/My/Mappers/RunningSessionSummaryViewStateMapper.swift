//
//  RunningSessionSummaryViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation

struct RunningSessionSummaryViewStateMapper {
    static func map(
        from entities: [RunningSessionSummary],
        currentDate: Date = Date()
    ) -> [RunningSessionSummaryViewState] {
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: currentDate)
        
        // 오늘 인증된 세션이 있는지 확인
        let hasSelfiedToday = entities.contains { entity in
            entity.isSelfied && entity.createdAt >= startOfToday
        }
        
        let dateFormatter = DateFormatterManager.shared
        let runningFormatter = RunningFormatterManager.shared
        
        return entities.map { entity in
            // MARK: 날짜 / 시간 텍스트
            let dateText = dateFormatter.formatDateWithWeekdayText(from: entity.createdAt)
            let timeText = dateFormatter.formatTime(from: entity.createdAt)
            
            // MARK: 거리 / 시간 / 페이스
            let distanceText = runningFormatter.formatDistance(from: entity.totalDistanceMeters)
            let durationText = runningFormatter.formatDuration(from: entity.totalDurationSeconds)
            let paceText = runningFormatter.formatPace(from: entity.avgPaceSecPerKm)
            let spmText = runningFormatter.formatCadence(from: entity.avgCadenceSpm)
            
            // MARK: 인증 상태 계산 (전체 컨텍스트 기반)
            let tagStatus: CertificationStatus = {
                let isToday = entity.createdAt >= startOfToday
                
                if entity.isSelfied {
                    return .completed
                }
                
                if isToday {
                    return hasSelfiedToday ? .none : .possible
                } else {
                    return .none
                }
            }()
            
            return RunningSessionSummaryViewState(
                id: entity.sessionId,
                date: entity.finishedAt,
                dateText: dateText,
                timeText: timeText,
                distanceText: distanceText,
                durationText: durationText,
                paceText: paceText,
                spmText: spmText,
                tagStatus: tagStatus,
                mapImageURL: entity.mapImageURL
            )
        }
    }
}
