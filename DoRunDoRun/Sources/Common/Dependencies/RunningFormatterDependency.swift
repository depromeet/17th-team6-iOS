//
//  RunningFormatterDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

enum RunningFormatterKey: DependencyKey {
    static let liveValue = RunningFormatterManager()
}

extension DependencyValues {
    var runningFormatter: RunningFormatterManager {
        get { self[RunningFormatterKey.self] }
        set { self[RunningFormatterKey.self] = newValue }
    }
}
