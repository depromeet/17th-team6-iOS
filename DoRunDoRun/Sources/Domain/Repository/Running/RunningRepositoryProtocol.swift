//
//  RunningRepositoryProtocol.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/25/25.
//

import Foundation

protocol RunningRepositoryProtocol: AnyObject {
    /// 러닝 시작: 스냅샷 스트림을 수명 내내 유지
    func startRun() async throws -> AsyncThrowingStream<RunningSnapshot, Error>
    /// 일시 정지(누적 유지, 센서/소비 중단)
    func pause() async
    /// 재개(누적 유지, 센서 재시작 및 재구독)
    func resume() async throws
    /// 종료(누적 초기화 및 스트림 종료)
    func stopRun() async
}
