//
//  RunningFormatterManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation

final class RunningFormatterManager {
    // MARK: - Distance
    func formatDistance(from meters: Double) -> String {
        let km = RunningConverterManager.metersToKilometers(meters)
        return String(format: "%.2fkm", km)
    }
    
    // MARK: - Duration
    func formatDuration(from seconds: Int) -> String {
        let (h, m, s) = RunningConverterManager.secondsToHMS(seconds)
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }
    
    // MARK: - Pace
    func formatPace(from speed: Double) -> String {
        guard let secPerKm = RunningConverterManager.speedToPace(speed) else { return "0'00\"" }
        let pace = Int(secPerKm)
        return String(format: "%d'%02d\"", pace / 60, pace % 60)
    }
    
    // MARK: - Cadence
    func formatCadence(from spm: Double) -> String {
        "\(RunningConverterManager.cadenceToInt(spm)) spm"
    }
}
