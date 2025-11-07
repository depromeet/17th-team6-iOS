//
//  RunningSessionSummaryViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation

struct RunningSessionSummaryViewStateMapper {
    static func map(from entity: RunningSessionSummary) -> RunningSessionSummaryViewState {
        let formatter = DateFormatterManager.shared
        
        // MARK: 날짜 / 시간 텍스트
        let dateText = formatter.formatDateWithWeekdayText(from: entity.createdAt)
        let timeText = formatter.formatTime(from: entity.createdAt)
        
        // MARK: 거리 / 시간 / 페이스
        let distanceText = String(format: "%.2fkm", entity.totalDistanceMeters / 1000)
        let durationText = formatDuration(entity.totalDurationSeconds)
        let paceText = formatPace(entity.avgPaceSecPerKm)
        let spmText = "\(entity.avgCadenceSpm) spm"
        
        // MARK: 인증 상태 계산
        let tagStatus: CertificationStatus = {
            if entity.isSelfied { return .completed }
            let elapsed = Date().timeIntervalSince(entity.finishedAt)
            return elapsed <= 48 * 3600 ? .possible : .none
        }()
        
        // MARK: ViewState 생성
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
            mapImageURL: String(describing: entity.mapImageURL)
        )
    }
}

// MARK: - Formatter Helpers
private extension RunningSessionSummaryViewStateMapper {
    static func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, secs)
            : String(format: "%02d:%02d", minutes, secs)
    }
    
    static func formatPace(_ seconds: Double) -> String {
        let paceSeconds = Int(seconds)
        let paceMin = paceSeconds / 60
        let paceSec = paceSeconds % 60
        return String(format: "%d'%02d\"", paceMin, paceSec)
    }
}
