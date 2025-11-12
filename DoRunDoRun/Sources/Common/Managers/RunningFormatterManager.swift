//
//  RunningFormatterManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation

/// 러닝 관련 거리·페이스·시간 포맷 전담 매니저
final class RunningFormatterManager {
    static let shared = RunningFormatterManager()
    private init() {}

    /// 거리 포맷 (m → km)
    func formatDistance(from meters: Double) -> String {
        let kilometers = meters / 1000
        return String(format: "%.2fkm", kilometers)
    }

    /// 러닝 시간 포맷 (초 → 00:00:00 또는 00:00)
    func formatDuration(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, secs)
            : String(format: "%02d:%02d", minutes, secs)
    }

    /// 페이스 포맷 (초/㎞ → m'ss")
    func formatPace(from seconds: Double) -> String {
        let paceSeconds = Int(seconds)
        let paceMin = paceSeconds / 60
        let paceSec = paceSeconds % 60
        return String(format: "%d'%02d\"", paceMin, paceSec)
    }

    /// 케이던스 포맷 (spm)
    func formatCadence(from spm: Double) -> String {
        "\(Int(spm)) spm"
    }
}
