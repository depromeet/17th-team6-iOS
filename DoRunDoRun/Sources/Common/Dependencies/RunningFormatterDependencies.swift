//
//  RunningFormatterDependencies.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

enum RunningFormatterManagerKey: DependencyKey {
    static let liveValue = RunningFormatterManager()
}

extension DependencyValues {
    var runningFormatter: RunningFormatterManager {
        get { self[RunningFormatterManagerKey.self] }
        set { self[RunningFormatterManagerKey.self] = newValue }
    }
}
