//
//  RunningSessionSummaryViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation

struct RunningSessionSummaryViewStateMapper {
    static func map(from entity: RunningSessionSummary) -> RunningSessionSummaryViewState {
        let date = entity.finishedAt
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd (E)"
        let dateText = dateFormatter.string(from: entity.createdAt)
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "a hh:mm"
        let timeText = timeFormatter.string(from: entity.createdAt)
        
        let duration = formatDuration(TimeInterval(entity.totalDurationSeconds))
        
        let tagStatus: CertificationStatus = {
            if entity.isSelfied {
                return .completed
            }

            // 러닝 완료 후 48시간 이내면 "인증 가능"
            let elapsed = Date().timeIntervalSince(entity.finishedAt)
            if elapsed <= 48 * 3600 {
                return .possible
            }

            return .none
        }()
        
        return RunningSessionSummaryViewState(
            id: entity.sessionId,
            date: date,
            dateText: dateText,
            timeText: timeText,
            distanceText: String(format: "%.2fkm", entity.totalDistanceMeters / 1000),
            durationText: duration,
            paceText: formatPace(entity.avgPaceSecPerKm),
            spmText: "\(entity.avgCadenceSpm) spm",
            tagStatus: tagStatus,
            mapImageURL: String(describing: entity.mapImageURL)
        )
    }
    
    private static func formatDuration(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
    private static func formatPace(_ secondsPerKm: Double) -> String {
        let min = Int(secondsPerKm) / 60
        let sec = Int(secondsPerKm) % 60
        return "\(min)'\(sec)\""
    }
}
