//
//  RunningWorker.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/26/25.
//

import Foundation

struct RunningWorker {
    private let repository: RunningRepositoryProtocol

    init(repository: RunningRepositoryProtocol) {
        self.repository = repository
    }

    func startRun() async throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        try await repository.startRun()
    }

    func pause() async {
        await repository.pause()
    }

    func resume() async throws {
        try await repository.resume()
    }

    func stopRun() async {
        await repository.stopRun()
    }
}
