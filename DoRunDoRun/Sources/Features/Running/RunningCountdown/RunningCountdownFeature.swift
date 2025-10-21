//
//  RunningCountdownFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import ComposableArchitecture

@Reducer
struct RunningCountdownFeature {
    @ObservableState
    struct State: Equatable {
        /// 현재 카운트 숫자 (3 → 2 → 1 → nil)
        var count: Int? = nil

        /// 카운트다운 시작 전 대기 상태 (“잠시 후 러닝 시작”만 보여줌)
        var isPreparing: Bool = true
    }

    enum Action: Equatable {
        case onAppear
        case updateCountdown(Int?)
        case countdownCompleted
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                state.isPreparing = true
                return .run { send in
                    try await Task.sleep(for: .seconds(1)) // “잠시 후” 표시
                    await send(.updateCountdown(3))
                    try await Task.sleep(for: .seconds(1))
                    await send(.updateCountdown(2))
                    try await Task.sleep(for: .seconds(1))
                    await send(.updateCountdown(1))
                    try await Task.sleep(for: .seconds(1))
                    await send(.countdownCompleted)
                }

            case let .updateCountdown(value):
                state.count = value
                state.isPreparing = false
                return .none

            case .countdownCompleted:
                state.count = nil
                state.isPreparing = false
                return .none
            }
        }
    }
}
