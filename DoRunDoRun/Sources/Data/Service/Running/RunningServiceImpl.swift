//
//  RunningServiceImpl.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/21/25.
//

import Foundation
import CoreLocation
import CoreMotion

enum RunningSensorEvent {
    case location(CLLocation)
    case pedometer(CMPedometerData)
}

protocol RunningService: AnyObject {
    func start() throws -> AsyncThrowingStream<RunningSensorEvent, Error>
    func stop() async
}

final class RunningServiceImpl: RunningService {
    // MARK: Dependencies
    private let locationService: LocationService
    private let motionService: MotionService
    
    // MARK: Streaming
    private var continuation: AsyncThrowingStream<RunningSensorEvent, Error>.Continuation?
    private var tasks: [Task<Void, Never>] = []
    private var state: State = .idle
    
    private enum State { case idle, running, stopped }
    
    init(locationService: LocationService, motionService: MotionService) {
        self.locationService = locationService
        self.motionService = motionService
    }
    
    // MARK: API
    func start() throws -> AsyncThrowingStream<RunningSensorEvent, Error> {
        guard state == .idle || state == .stopped else {
            throw RunningError.alreadyRunning
        }
        state = .running
        
        let locationStream = try locationService.startTracking()
        let motionStream = try motionService.startTracking()
        
        let (stream, cont) = AsyncThrowingStream<RunningSensorEvent, Error>.makeStream()
        continuation = cont
        
        let t1 = makeLocationTask(stream: locationStream)
        let t2 = makeMotionTask(stream: motionStream)
        tasks = [t1, t2]
        
        return stream
    }
    
    func stop() async {
        guard state == .running else { return }
        state = .stopped
        
        cancelTasks()
        locationService.stopTracking()
        motionService.stopTracking()
        continuation?.finish()
        continuation = nil
    }
}

// MARK: - Task builders
private extension RunningServiceImpl {
    func makeLocationTask(stream: AsyncThrowingStream<CLLocation, Error>) -> Task<Void, Never> {
        Task { [weak self] in
            guard let self else { return }
            do {
                for try await loc in stream {
                    if Task.isCancelled { break }
                    self.continuation?.yield(.location(loc))
                }
            } catch is CancellationError {
                // 정상 취소
            } catch {
                await self.finishWith(error: self.mapError(error, origin: .location))
            }
        }
    }
    
    func makeMotionTask(stream: AsyncThrowingStream<CMPedometerData, Error>) -> Task<Void, Never> {
        Task { [weak self] in
            guard let self else { return }
            do {
                for try await ped in stream {
                    if Task.isCancelled { break }
                    self.continuation?.yield(.pedometer(ped))
                }
            } catch is CancellationError {
                // 정상 취소
            } catch {
                await self.finishWith(error: self.mapError(error, origin: .motion))
            }
        }
    }
}

// MARK: - Helpers
private extension RunningServiceImpl {
    enum ErrorOrigin { case location, motion }
    
    func cancelTasks() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    func mapError(_ error: Error, origin: ErrorOrigin) -> RunningError {
        if let le = error as? LocationServiceError {
            switch le {
            case .notAuthorized:      return .locationNotAuthorized
            case .alreadyStreaming:   return .runtime(le)
            case .runtimeError(let e):return .runtime(e)
            }
        }
        if let me = error as? MotionServiceError {
            switch me {
            case .notAuthorized:      return .motionNotAuthorized
            case .unavailable:        return .sensorUnavailable
            case .alreadyStreaming:   return .runtime(me)
            case .runtimeError(let e):return .runtime(e)
            }
        }
        return .runtime(error)
    }
    
    func finishWith(error: RunningError) async {
        continuation?.finish(throwing: error)
        continuation = nil
        cancelTasks()
        state = .stopped
    }
}
