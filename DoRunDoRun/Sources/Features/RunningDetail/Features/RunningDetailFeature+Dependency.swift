//
//  RunningDetailFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import ComposableArchitecture

extension DependencyValues {
    var runningSessionCompleter: RunningSessionCompleterProtocol {
        get { self[RunningSessionCompleterKey.self] }
        set { self[RunningSessionCompleterKey.self] = newValue }
    }
}

// MARK: - Keys

private enum RunningSessionCompleterKey: DependencyKey {
    static let liveValue: RunningSessionCompleterProtocol = RunningSessionCompleter(
        sessionRepository: RunningSessionRepositoryImpl()
    )

    static let testValue: RunningSessionCompleterProtocol = RunningSessionCompleter(
        sessionRepository: RunningSessionRepositoryMock()
    )

    static let previewValue: RunningSessionCompleterProtocol = RunningSessionCompleter(
        sessionRepository: RunningSessionRepositoryMock()
    )
}
