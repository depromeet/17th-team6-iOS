//
//  UploadFeedFeature.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct UploadFeedFeature {
    @ObservableState
    struct State {
        var isLoaded = false
        var runningRecords: [RunningRecord] = []
    }

    enum Action {
        case fetchRunningRecords
        case runningRecordsResponse(Result<[RunningRecord], Error>)
    }

    @Dependency(\.getRunningRecordsRepository) var runningRecordRepository: RunningRecordRepositoryProtocol

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .fetchRunningRecords:
                    return .run { send in
                        do {
                            let worker = RunningWorker(repository: runningRecordRepository)
                            let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: .now)
                            let result = try await worker.runningRecords(isSelfied: true, startDateTime: twoDaysAgo, endDateTime: .now)
                            await send(.runningRecordsResponse(.success(result)))
                        } catch {
                            await send(.runningRecordsResponse(.failure(error)))
                        }
                    }
                case let .runningRecordsResponse(result):
                    print("ABC", result)
                    state.isLoaded = true
                    if case let .success(records) = result {
                        state.runningRecords = records
                    }

                    return .none
            }
        }
    }
}

extension DependencyValues {
    var getRunningRecordsRepository: RunningRecordRepositoryProtocol {
        get { self[RunningRecordsRepositoryKey.self] }
        set { self[RunningRecordsRepositoryKey.self] = newValue }
    }
}

private enum RunningRecordsRepositoryKey: DependencyKey {
    static let liveValue: RunningRecordRepositoryProtocol = RunningRecordRepository()
    static let testValue: RunningRecordRepositoryProtocol = RunningRecordRepositoryMock()
    static let previewValue: RunningRecordRepositoryProtocol = RunningRecordRepositoryMock()
}
