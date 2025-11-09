//
//  Untitled.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/2/25.
//

extension Int {
    func formatTime() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let secs = self % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    func formatPace() -> String {
        let minutes = self / 60
        let secs = self % 60

        return String(format: "%d'%02d\"", minutes, secs)
    }

    func formatDistance() -> String {
        let km = Double(self) / 1000.0
        return String(format: "%.2fkm", km)
    }
}

