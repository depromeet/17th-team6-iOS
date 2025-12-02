//
//  RunningConverterManager.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/17/25.
//

enum RunningConverterManager {
    /// m → km
    static func metersToKilometers(_ meters: Double) -> Double {
        meters / 1000
    }

    /// sec → (h, m, s)
    static func secondsToHMS(_ seconds: Int) -> (h: Int, m: Int, s: Int) {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return (hours, minutes, secs)
    }

    /// m/s → sec/km
    static func speedToPace(_ speed: Double) -> Double? {
        guard speed > 0 else { return nil }
        return 1000 / speed
    }

    /// spm(Double) → spm(Int)
    static func cadenceToInt(_ spm: Double) -> Int {
        Int(spm)
    }
}
