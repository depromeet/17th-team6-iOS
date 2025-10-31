//
//  RunningDetailViewStateMapper.swift
//
//
//  Created by zaehorang on 10/31/25.
//


import Foundation

struct RunningDetailViewStateMapper {
    static func map(from detail: RunningDetail) -> RunningDetailViewState {
        // FinishedAt → "2025.10.09 · 오전 10:11" 형식으로
        let finishedAtText = formatDate(detail.finishedAt)
        
        let distanceText = formatDistance(detail.totalDistanceMeters)
        
        // Duration → "1:52:06" 형식으로
        let elapsedText = formatDuration(detail.elapsed)
        
        // Pace → "7'30\"" 형식으로
        let paceText = formatPace(detail.avgPaceSecPerKm)
        
        // Cadence → "144 spm" 형식으로
        let cadenceText = "\(Int(detail.avgCadenceSpm)) spm"
        
        return RunningDetailViewState(
            finishedAtText: finishedAtText,
            totalDistanceText: distanceText,
            avgPaceText: paceText,
            durationText: elapsedText,
            cadenceText: cadenceText,
            mapImageURL: detail.mapImageURL,
            feed: detail.feed
        )
    }
}

// MARK: - Formatter Helpers
private extension RunningDetailViewStateMapper {
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd · a hh:mm"
        return formatter.string(from: date)
    }
    
    static func formatDistance(_ distanceMeters: Double) -> String {
        let km = distanceMeters / 1000
        return String(format: "%.2fkm", km)
    }
    
    static func formatDuration(_ duration: Duration) -> String {
        let totalSeconds = Int(duration.components.seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    static func formatPace(_ paceSecPerKm: Double) -> String {
        let totalSeconds = Int(paceSecPerKm)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
}
