//
//  RunningActiveUseCase.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/22/25.
//

protocol RunningActiveUseCaseProtocol {
    /// 러닝을 시작하고 스냅샷 스트림을 반환
    func start() async throws -> AsyncThrowingStream<RunningSnapshot, Error>
    func pause() async
    func resume() async throws
    func stop() async
}

//TODO: Server에 데이터 전달하는 로직 추가
final class RunningActiveUseCase: RunningActiveUseCaseProtocol {
    private let repository: RunningRepository
    
    init(repository: RunningRepository) {
        self.repository = repository
    }
    
    func start() async throws -> AsyncThrowingStream<RunningSnapshot, Error> {
        try await repository.startRun()
    }
    
    func pause() async {
        await repository.pause()
    }
    
    func resume() async throws {
        try await repository.resume()
    }
    
    func stop() async {
        await repository.stopRun()
    }
}
