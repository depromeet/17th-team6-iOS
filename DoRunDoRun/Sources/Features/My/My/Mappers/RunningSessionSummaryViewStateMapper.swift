//
//  RunningSessionSummaryViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
//

import Foundation

struct RunningSessionSummaryViewStateMapper {
    /// RunningSessionSummary Entity → RunningSessionSummaryViewState 변환
    static func map(from entity: RunningSessionSummary) -> RunningSessionSummaryViewState {
        // MARK: 날짜 / 시간 텍스트
        let dateFormatter = DateFormatterManager.shared
        let dateText = dateFormatter.formatDateWithWeekdayText(from: entity.createdAt)
        let timeText = dateFormatter.formatTime(from: entity.createdAt)
        
        // MARK: 거리 / 시간 / 페이스
        let runningFormatter = RunningFormatterManager.shared
        let distanceText = runningFormatter.formatDistance(from: entity.totalDistanceMeters)
        let durationText = runningFormatter.formatDuration(from: entity.totalDurationSeconds)
        let paceText = runningFormatter.formatPace(from: entity.avgPaceSecPerKm)
        let spmText = runningFormatter.formatCadence(from: entity.avgCadenceSpm)
        
        // MARK: 인증 상태 계산
        let tagStatus: CertificationStatus = {
            // 이미 인증한 경우
            if entity.isSelfied { return .completed }
            
            // 오늘 날짜의 00:00 시각 계산
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            
            // createdAt이 오늘 이후면 인증 가능
            if entity.createdAt >= startOfToday {
                return .possible
            } else {
                return .none
            }
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

    /// RunningDetailViewState → RunningSessionSummaryViewState 변환
    static func mapFromDetail(from detail: RunningDetailViewState) -> RunningSessionSummaryViewState {
        // MARK: 날짜 / 시간 텍스트
        let dateText = formatDate(detail.startedAt)
        let timeText = formatTime(detail.startedAt)
        
        // MARK: 인증 상태 계산
        let tagStatus: CertificationStatus = {
            // 오늘 날짜의 00:00 시각 계산
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())

            // startedAt이 오늘 이후면 인증 가능
            if detail.startedAt >= startOfToday {
                return .possible
            } else {
                return .none
            }
        }()

        // MARK: ViewState 생성
        return RunningSessionSummaryViewState(
            id: detail.sessionId ?? 0,
            date: detail.startedAt,
            dateText: dateText,
            timeText: timeText,
            distanceText: detail.totalDistanceText,
            durationText: detail.durationText,
            paceText: detail.avgPaceText,
            spmText: detail.cadenceText,
            tagStatus: tagStatus,
            mapImageURL: detail.mapImageURL?.absoluteString
        )
    }
}

private extension RunningSessionSummaryViewStateMapper {
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh:mm"
        return formatter.string(from: date)
    }
}
